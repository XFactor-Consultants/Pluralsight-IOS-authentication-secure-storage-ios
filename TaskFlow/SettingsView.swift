import SwiftUI

struct SettingsView: View {
    @Environment(TasksStore.self) private var tasksStore
    @Environment(AuthStore.self) private var authStore
    @Environment(LocalContentCache.self) private var contentCache

    var body: some View {
        NavigationStack {
            Form {
                // Module 1, Clip 2 replaces this section with the signed-in
                // user's ID and a working Sign Out button backed by AuthStore.
                Section("Account") {
                    if case .signedIn(let userID) = authStore.state {
                        LabeledContent("User", value: userID)
                    }
                    LabeledContent("Session",
                                   value: authStore.hasStoredSession ? "Stored on this device" : "None")
                    Button("Sign Out", role: .destructive) {
                        Task { await authStore.signOut() }
                    }
                    #if DEBUG
                    Button("Force Expire Session") {
                        Task { await authStore.debugForceExpire() }
                    }
                    #endif
                    #if DEBUG
                    Button("Tamper With Cached Content") {
                        contentCache.debugCorruptFirstEntry()
                    }
                    #endif
                }

                Section("Workspace") {
                    LabeledContent("Open Tasks", value: "\(tasksStore.tasks.filter { !$0.isComplete }.count)")
                    LabeledContent("Teammates", value: "\(tasksStore.teammates.count)")
                }

                Section("Team") {
                    ForEach(tasksStore.teammates) { teammate in
                        HStack {
                            Text(teammate.initials)
                                .font(.caption)
                                .padding(6)
                                .background(.quaternary, in: Circle())
                            Text(teammate.name)
                        }
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0 (canonical build)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(TasksStore())
        .environment(AuthStore(contentCache: LocalContentCache()))
        .environment(LocalContentCache())
}
