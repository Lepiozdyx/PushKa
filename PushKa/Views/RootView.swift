import SwiftUI

@MainActor
final class AppStateViewModel: ObservableObject {
    
    enum AppState {
        case fetch
        case supp
        case final
    }
    
    @Published private(set) var appState: AppState = .fetch
    let webManager: NetworkManager
    
    private var timeoutTask: Task<Void, Never>?
    private let maxLoadingTime: TimeInterval = 10.0
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        timeoutTask?.cancel()
        
        Task { @MainActor in
            do {
                if webManager.targetURL != nil {
                    updateState(.supp)
                    return
                }
                
                let shouldShowWebView = try await webManager.checkInitialURL()
                
                if shouldShowWebView {
                    updateState(.supp)
                } else {
                    updateState(.final)
                }
                
            } catch {
                updateState(.final)
            }
        }
        
        startTimeoutTask()
    }
    
    private func updateState(_ newState: AppState) {
        timeoutTask?.cancel()
        timeoutTask = nil
        
        appState = newState
    }
    
    private func startTimeoutTask() {
        timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(maxLoadingTime * 1_000_000_000))
                
                if self.appState == .fetch {
                    self.appState = .final
                }
            } catch {}
        }
    }
    
    deinit {
        timeoutTask?.cancel()
    }
}

struct RootView: View {
    
    @StateObject private var state = AppStateViewModel()
        
    var body: some View {
        Group {
            switch state.appState {
            case .fetch:
                LoadingView()
                
            case .supp:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                }
                
            case .final:
                ContentView()
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    RootView()
}
