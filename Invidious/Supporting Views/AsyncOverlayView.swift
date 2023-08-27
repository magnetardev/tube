import SwiftUI

class RefreshHandler: ObservableObject {
    @Published private(set) var isRefreshing = false

    func refresh(_ action: RefreshAction) async {
        guard !isRefreshing else { return }
        await MainActor.run {
            isRefreshing = true
        }
        await action()
        await MainActor.run {
            isRefreshing = false
        }
    }
}

struct AsyncOverlayView: View {
    var error: Error?
    var isLoading: Bool
    @StateObject private var refreshHandler = RefreshHandler()
    @Environment(\.refresh) private var action

    var body: some View {
        VStack(spacing: 4) {
            if let error = error {
                VStack {
                    Text("Something went wrong")
                        .font(.headline)
                        .fontWeight(.medium)
                    Text(error.localizedDescription)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    if let action = action {
                        Button {
                            Task {
                                await refreshHandler.refresh(action)
                            }
                        } label: {
                            ZStack {
                                if refreshHandler.isRefreshing {
                                    ProgressView()
                                } else {
                                    Text("Retry")
                                }
                            }
                        }.disabled(refreshHandler.isRefreshing)
                            .padding(.top, 8)
                    }
                }.padding().background(Rectangle().foregroundStyle(.windowBackground))
            } else if isLoading {
                ProgressView().background(Rectangle().foregroundStyle(.windowBackground))
            }
        }.padding()
    }
}
