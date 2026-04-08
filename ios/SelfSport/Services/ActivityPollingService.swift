import Foundation
import Supabase

@Observable
final class ActivityPollingService {
    var newActivitiesCount: Int = 0

    private let activityService = SupabaseActivityService()
    private let pollingInterval: TimeInterval = 300
    private var pollingTask: Task<Void, Never>?
    private var lastKnownLatestDate: String?
    private var onNewActivities: (([StravaActivity]) -> Void)?

    func configure(onNewActivities: @escaping ([StravaActivity]) -> Void) {
        self.onNewActivities = onNewActivities
    }

    func startPolling() {
        stopPolling()
        pollingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(pollingInterval))
                guard !Task.isCancelled else { break }
                await checkForNewActivities()
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func setLastKnownDate(_ date: String?) {
        lastKnownLatestDate = date
    }

    func checkForNewActivities() async {
        do {
            let webhookActivities = try await fetchWebhookSyncedActivities()
            guard !webhookActivities.isEmpty else { return }

            let stravaActivities = webhookActivities.map { $0.toStravaActivity() }
            newActivitiesCount = stravaActivities.count
            onNewActivities?(stravaActivities)

            for activity in stravaActivities {
                await NotificationService.shared.scheduleLocalNotification(
                    title: "New activity synced",
                    body: activity.name,
                    identifier: "webhook_activity_\(activity.id)"
                )
            }

            try await markWebhookActivitiesAsSeen(webhookActivities)

            if let newest = webhookActivities.first?.startDateLocal {
                lastKnownLatestDate = newest
            }
        } catch {
            // Silent
        }
    }

    private func fetchWebhookSyncedActivities() async throws -> [SupabaseActivityRow] {
        guard let userId = try? await supabase.auth.session.user.id.uuidString else { return [] }

        let rows: [SupabaseActivityRow] = try await supabase
            .from("strava_activities")
            .select()
            .eq("user_id", value: userId)
            .eq("synced_by_webhook", value: true)
            .order("start_date_local", ascending: false)
            .execute()
            .value

        return rows
    }

    private func markWebhookActivitiesAsSeen(_ activities: [SupabaseActivityRow]) async throws {
        guard let userId = try? await supabase.auth.session.user.id.uuidString else { return }

        let ids = activities.compactMap { $0.stravaActivityId }
        for id in ids {
            try await supabase
                .from("strava_activities")
                .update(["synced_by_webhook": AnyJSON.bool(false)])
                .eq("user_id", value: userId)
                .eq("strava_activity_id", value: id)
                .execute()
        }
    }
}
