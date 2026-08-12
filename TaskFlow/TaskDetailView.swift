import SwiftUI

struct TaskDetailView: View {
    @Environment(TasksStore.self) private var tasksStore
    @Environment(AuthStore.self) private var authStore
    @Environment(LocalContentCache.self) private var contentCache
    @State private var gate = BiometricGate()
    let task: TaskItem

    var body: some View {
        Group {
            if task.isSensitive && !gate.isUnlocked {
                LockedTaskView(gate: gate)
                    .navigationTitle("Task")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                taskForm
            }
        }
        .task {
            await authStore.refreshIfNeeded()
        }
    }

    private var taskForm: some View {
        Form {
            Section {
                HStack {
                    Text(task.title)
                        .font(.headline)
                    if task.isSensitive {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .foregroundStyle(.secondary)
                }
                Button("Copy Note") {
                    
                    UIPasteboard.general.string = task.notes
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        
                        if UIPasteboard.general.string == task.notes {
                            
                            UIPasteboard.general.string = ""
                            
                        }
                        
                    }
                    
                }

            }

            Section("Details") {
                if let assignee = task.assignee {
                    LabeledContent("Assigned to", value: assignee.name)
                }
                if let dueDate = task.dueDate {
                    LabeledContent("Due") {
                        Text(dueDate.formatted(date: .long, time: .omitted))
                            .foregroundStyle(task.isOverdue ? .red : .secondary)
                    }
                }
                LabeledContent("Priority") {
                    Label(task.priority.label, systemImage: task.priority.systemImage)
                }
                if task.isSensitive {
                    LabeledContent("Sensitive", value: "Yes")
                }
            }

            Section {
                Button(task.isComplete ? "Mark as Not Complete" : "Mark as Complete") {
                    tasksStore.toggleComplete(task)
                }
            }
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ShareLink(item: task.shareSummary) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .onAppear {
            contentCache.store(task.notes, for: task.id)
        }
    }
}

struct LockedTaskView: View {
    let gate: BiometricGate

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("This task is sensitive.")
                .font(.headline)
            if let message = gate.unavailableMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button("Unlock") {
                Task { await gate.requestUnlock() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: TasksStore().tasks[0])
    }
    .environment(TasksStore())
}
