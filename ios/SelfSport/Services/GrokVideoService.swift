import Foundation
import UIKit
import Supabase

nonisolated struct VideoGenerationResponse: Codable, Sendable {
    let requestId: String?
    let error: String?
    let details: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case error
        case details
    }
}

nonisolated struct VideoStatusResponse: Codable, Sendable {
    let status: String
    let videoUrl: String?
    let error: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case status
        case videoUrl = "video_url"
        case error
    }
}

nonisolated enum VideoGenerationError: Error, LocalizedError, Sendable {
    case imageConversionFailed
    case networkError
    case serverError(String)
    case expired
    case cancelled

    nonisolated var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to process the image"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return message
        case .expired:
            return "Video generation expired. Please try again."
        case .cancelled:
            return "Video generation was cancelled"
        }
    }
}

final class GrokVideoService {
    private let pollingInterval: TimeInterval = 5.0
    private let maxPollingDuration: TimeInterval = 300.0
    private(set) var videoStyles: [VideoStylePrompt] = []

    private var supabaseBaseURL: String {
        Config.EXPO_PUBLIC_SUPABASE_URL.isEmpty
            ? "https://placeholder.supabase.co"
            : Config.EXPO_PUBLIC_SUPABASE_URL
    }

    private var functionBaseURL: String {
        "\(supabaseBaseURL)/functions/v1/grok-video-generate"
    }

    private var anonKey: String {
        Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
    }

    func loadVideoStyles() async {
        do {
            let rows: [VideoStylePrompt] = try await supabase
                .from("video_style_prompts")
                .select()
                .eq("is_active", value: true)
                .order("sort_order")
                .execute()
                .value
            videoStyles = rows
        } catch {
            print("[GrokVideo] Failed to load video styles: \(error)")
        }
    }

    func promptTemplate(for styleKey: String) -> String? {
        videoStyles.first(where: { $0.styleKey == styleKey })?.promptTemplate
    }

    private func resizedImage(_ image: UIImage, maxDimension: CGFloat = 1280) -> UIImage {
        let size = image.size
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return image }
        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func startGeneration(image: UIImage, prompt: String? = nil) async throws -> String {
        let resized = resizedImage(image)
        guard let jpegData = resized.jpegData(compressionQuality: 0.6) else {
            throw VideoGenerationError.imageConversionFailed
        }

        let base64String = jpegData.base64EncodedString()

        let url = URL(string: functionBaseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 120

        var body: [String: Any] = [
            "image_base64": base64String
        ]
        if let prompt, !prompt.isEmpty {
            body["prompt"] = prompt
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[GrokVideo] Sending base64 image (\(base64String.count) chars) to edge function")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VideoGenerationError.networkError
        }

        let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
        print("[GrokVideo] Response HTTP \(httpResponse.statusCode): \(String(responseBody.prefix(300)))")

        guard httpResponse.statusCode == 200 else {
            let decoded = try? JSONDecoder().decode(VideoGenerationResponse.self, from: data)
            let detail = decoded?.details ?? decoded?.error ?? String(responseBody.prefix(300))
            throw VideoGenerationError.serverError("HTTP \(httpResponse.statusCode): \(detail)")
        }

        let decoded = try JSONDecoder().decode(VideoGenerationResponse.self, from: data)

        guard let requestId = decoded.requestId else {
            throw VideoGenerationError.serverError(decoded.error ?? "No request ID returned")
        }

        print("[GrokVideo] Got request_id: \(requestId)")
        return requestId
    }

    func pollUntilDone(requestId: String) async throws -> URL {
        let startTime = Date()

        while true {
            try Task.checkCancellation()

            if Date().timeIntervalSince(startTime) > maxPollingDuration {
                throw VideoGenerationError.expired
            }

            try await Task.sleep(for: .seconds(pollingInterval))
            try Task.checkCancellation()

            let status = try await checkStatus(requestId: requestId)
            print("[GrokVideo] Poll status: \(status.status)")

            switch status.status {
            case "done":
                guard let urlString = status.videoUrl,
                      let url = URL(string: urlString) else {
                    throw VideoGenerationError.serverError("No video URL in response")
                }
                return url
            case "expired":
                throw VideoGenerationError.expired
            default:
                continue
            }
        }
    }

    func downloadVideo(from remoteURL: URL) async throws -> URL {
        let (data, response) = try await URLSession.shared.data(from: remoteURL)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw VideoGenerationError.networkError
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("grok_video_\(UUID().uuidString).mp4")
        try data.write(to: fileURL)
        return fileURL
    }

    private func checkStatus(requestId: String) async throws -> VideoStatusResponse {
        var components = URLComponents(string: functionBaseURL)!
        components.queryItems = [URLQueryItem(name: "request_id", value: requestId)]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VideoGenerationError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            throw VideoGenerationError.serverError("Poll HTTP \(httpResponse.statusCode): \(String(responseBody.prefix(200)))")
        }

        return try JSONDecoder().decode(VideoStatusResponse.self, from: data)
    }
}
