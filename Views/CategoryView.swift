import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fsBackground.ignoresSafeArea()
                Text("Tutaj będą kategorie")
                    .foregroundColor(Color.fsSecondary)
            }
            .navigationTitle("Kategorie")
        }
    }
}

#Preview {
    CategoryView()
}
