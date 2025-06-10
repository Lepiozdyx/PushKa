import SwiftUI

struct LoadingView: View {
    @State private var loading: CGFloat = 0
    
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
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Loading...")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                    
                        Capsule()
                            .foregroundStyle(.black.opacity(0.5))
                            .frame(maxWidth: 250, maxHeight: 20)
                            .overlay {
                                Capsule()
                                    .stroke(.gray, lineWidth: 1)
                            }
                            .overlay(alignment: .top) {
                                Capsule()
                                    .foregroundStyle(.white.opacity(0.3))
                                    .frame(height: 3)
                                    .padding(.horizontal, 10)
                                    .padding(.top, 3)
                            }
                            .shadow(radius: 2)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .foregroundStyle(.red.opacity(0.85))
                                    .frame(width: 248 * loading, height: 18)
                                    .padding(.horizontal, 1)
                            }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5)) {
                loading = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
