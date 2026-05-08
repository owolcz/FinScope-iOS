//
//  CategoryView 2.swift
//  FinScope
//
//  Created by Justynka  on 04/05/2026.
//


import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationStack {
            Text("Tutaj będą kategorie")
                .navigationTitle("Kategorie")
        }
    }
}

#Preview {
    CategoryView()
}
