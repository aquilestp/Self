import Foundation
import UIKit
import Supabase

final class GrokImageEditService {
    private var cachedPrompts: [String: String] = [:]

    func loadPrompts() async {
        do {
            let rows: [EditStylePrompt] = try await supabase
                .from("edit_style_prompts")
                .select()
                .eq("is_active", value: true)
                .execute()
                .value

            var map: [String: String] = [:]
            for row in rows {
                map[row.styleKey] = row.promptTemplate
            }
            cachedPrompts = map
        } catch {
            print("Failed to load edit style prompts: \(error)")
        }
    }

    func prompt(for styleKey: String) -> String? {
        cachedPrompts[styleKey]
    }

    func generateEditedImage(photo: UIImage, styleKey: String) async throws -> UIImage {
        guard let jpegData = photo.jpegData(compressionQuality: 0.8) else {
            throw GrokEditError.imageConversionFailed
        }

        let base64String = jpegData.base64EncodedString()

        let baseURL = Config.EXPO_PUBLIC_SUPABASE_URL.isEmpty
            ? "https://placeholder.supabase.co"
            : Config.EXPO_PUBLIC_SUPABASE_URL
        let functionURL = URL(string: "\(baseURL)/functions/v1/grok-image-edit")!
        let anonKey = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY

        var request = URLRequest(url: functionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "image_base64": base64String,
            "style_key": styleKey,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[GrokImageEdit] Calling: \(functionURL.absoluteString)")
        print("[GrokImageEdit] Style: \(styleKey), Image size: \(base64String.count) chars")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GrokEditError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("[GrokImageEdit] HTTP \(httpResponse.statusCode) - Body: \(responseBody)")
            let decoded = try? JSONDecoder().decode(GrokEditResponse.self, from: data)
            let detail = decoded?.error ?? responseBody.prefix(200).description
            throw GrokEditError.serverError("HTTP \(httpResponse.statusCode): \(detail)")
        }

        let decoded = try JSONDecoder().decode(GrokEditResponse.self, from: data)

        guard let imageBase64 = decoded.imageBase64,
              let imageData = Data(base64Encoded: imageBase64),
              let image = UIImage(data: imageData) else {
            throw GrokEditError.invalidResponse
        }

        return image
    }
}

enum GrokEditError: Error, LocalizedError, Sendable {
    case imageConversionFailed
    case networkError
    case serverError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to process the image"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
