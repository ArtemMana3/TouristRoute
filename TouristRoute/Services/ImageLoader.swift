//
//  ImageLoader.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 21.02.2024.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: Image? = nil

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            DispatchQueue.main.async {
                guard let uiImage = UIImage(data: data) else { return }
                self.image = Image(uiImage: uiImage)
            }
        }.resume()
    }
}
