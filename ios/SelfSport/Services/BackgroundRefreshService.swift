import BackgroundTasks
import Foundation

enum BackgroundRefreshService {
    static let taskIdentifier = "com.selfsport.webhook-check"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleRefresh(refreshTask)
        }
    }

    static func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Silent — background refresh is best-effort
        }
    }

    private static func handleRefresh(_ task: BGAppRefreshTask) {
        scheduleNextRefresh()

        let pollingService = ActivityPollingService()
        let checkTask = Task {
            await pollingService.checkForNewActivities()
        }

        task.expirationHandler = {
            checkTask.cancel()
        }

        Task {
            await checkTask.value
            task.setTaskCompleted(success: true)
        }
    }
}
