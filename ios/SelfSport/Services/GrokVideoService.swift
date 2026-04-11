import Foundation
import UIKit
import Supabase

nonisolated struct XAIVideoStartResponse: Codable, Sendable {
    let requestId: String?
    let error: XAIVideoError?

    nonisolated struct XAIVideoError: Codable, Sendable {
        let code: String?
        let message: String?
    }

    nonisolated enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case error
    }
}

nonisolated struct XAIVideoStatusResponse: Codable, Sendable {
    let status: String?
    let video: XAIVideo?
    let error: XAIVideoStatusError?

    nonisolated struct XAIVideo: Codable, Sendable {
        let url: String?
        let duration: Double?
    }

    nonisolated struct XAIVideoStatusError: Codable, Sendable {
        let code: String?
        let message: String?
    }
}

nonisolated enum VideoGenerationError: Error, LocalizedError, Sendable {
    case imageConversionFailed
    case networkError
    case serverError(String)
    case expired
    case cancelled
    case missingAPIKey

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
        case .missingAPIKey:
            return "Video generation is not configured"
        }
    }
}

final class GrokVideoService {
    private let pollingInterval: TimeInterval = 5.0
    private let maxPollingDuration: TimeInterval = 300.0
    private(set) var videoStyles: [VideoStylePrompt] = []

    private let xaiBaseURL = "https://api.x.ai/v1"

    private var apiKey: String {
        Config.EXPO_PUBLIC_XAI_API_KEY
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
        guard !apiKey.isEmpty else {
            throw VideoGenerationError.missingAPIKey
        }

        let resized = resizedImage(image)
        guard let jpegData = resized.jpegData(compressionQuality: 0.6) else {
            throw VideoGenerationError.imageConversionFailed
        }

        let base64String = jpegData.base64EncodedString()
        let dataURI = "data:image/jpeg;base64,\(base64String)"

        let url = URL(string: "\(xaiBaseURL)/videos/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 120

        var body: [String: Any] = [
            "model": "grok-imagine-video",
            "image": ["url": dataURI],
            "duration": 8,
            "resolution": "720p"
        ]
        if let prompt, !prompt.isEmpty {
            body["prompt"] = prompt
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[GrokVideo] Calling xAI directly, image size: \(base64String.count) chars")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VideoGenerationError.networkError
        }

        let responseBody = String(data: data, encoding: .utf8) ?? "No body"
        print("[GrokVideo] HTTP \(httpResponse.statusCode): \(String(responseBody.prefix(500)))")

        guard httpResponse.statusCode == 200 else {
            let decoded = try? JSONDecoder().decode(XAIVideoStartResponse.self, from: data)
            let detail = decoded?.error?.message ?? String(responseBody.prefix(300))
            throw VideoGenerationError.serverError("HTTP \(httpResponse.statusCode): \(detail)")
        }

        let decoded = try JSONDecoder().decode(XAIVideoStartResponse.self, from: data)

        guard let requestId = decoded.requestId else {
            throw VideoGenerationError.serverError(decoded.error?.message ?? "No request ID returned")
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
            let statusStr = status.status ?? "unknown"
            print("[GrokVideo] Poll status: \(statusStr)")

            switch statusStr {
            case "done":
                guard let urlString = status.video?.url,
                      let url = URL(string: urlString) else {
                    throw VideoGenerationError.serverError("No video URL in response")
                }
                return url
            case "failed":
                let msg = status.error?.message ?? "Video generation failed"
                throw VideoGenerationError.serverError(msg)
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

    private func checkStatus(requestId: String) async throws -> XAIVideoStatusResponse {
        guard !apiKey.isEmpty else {
            throw VideoGenerationError.missingAPIKey
        }

        let url = URL(string: "\(xaiBaseURL)/videos/\(requestId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VideoGenerationError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            throw VideoGenerationError.serverError("Poll HTTP \(httpResponse.statusCode): \(String(responseBody.prefix(200)))")
        }

        return try JSONDecoder().decode(XAIVideoStatusResponse.self, from: data)
    }
}
