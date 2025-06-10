import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.85),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.red.opacity(0.85))
                
                Text("Hello, world!")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(.red)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
