import SwiftUI

struct SettingsView: View {
    @Environment(TasksStore.self) private var tasksStore
    @Environment(AuthStore.self) private var authStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if case .signedIn(let userID) = authStore.state {
                        LabeledContent("User", value: userID)
                    }
                    LabeledContent("Session",
                                   value: authStore.hasStoredSession ? "Stored on this device" : "None")
                    Button("Sign Out", role: .destructive) {
                        authStore.signOut()
                    }
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
        .environment(AuthStore())
}
