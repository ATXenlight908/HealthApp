import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Image("amazon_health")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    LoadingView()
} 