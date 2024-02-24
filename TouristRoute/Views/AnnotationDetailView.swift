//
//  DetailView.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 21.02.2024.
//


import SwiftUI

struct AnnotationDetailView: View {
    var title: String
    @StateObject private var openAIController = OpenAIController() // Assumes this object has the generateText method
    @State private var generatedText: String?
    var imageUrl: URL
    @StateObject private var imageLoader = ImageLoader()
    var onRouteSelect: (String) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                if let image = imageLoader.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 250)
                        .clipped()
                } else {
                    ProgressView().onAppear {
                        imageLoader.loadImage(from: imageUrl)
                    }
                }
                
                if let generatedText = generatedText {
                    Text(generatedText)
                } else {
                    ProgressView()
                        .onAppear {
                            openAIController.generateText(from: "Write 3 sentences about this attraction, only the most important information I should know as a tourist. You need to use this forman 1. 2. 3. and also try to add some historical information, but not boring \(title)") { generatedText in
                                // Directly update the state variable upon completion
                                DispatchQueue.main.async {
                                    self.generatedText = generatedText ?? "Failed to generate text."
                                }
                            }
                        }
                }
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Route") {
                        onRouteSelect(title)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
