//
//  OpenAIController.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 22.02.2024.
//

import SwiftUI
import OpenAI

class OpenAIController: ObservableObject {
    @Published var generatedText: String = ""
    
    let openAI = OpenAI(apiToken: "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")
    
    func generateText(from prompt: String, completion: @escaping (String?) -> Void) {
        // Prepare the prompt as a single Chat message
        let queryPrompt = Chat(role: .user, content: prompt)
        
        // Make the request to OpenAI's API
        openAI.chats(query: .init(model: .gpt3_5Turbo, messages: [queryPrompt])) { result in
            switch result {
            case .success(let response):
                guard let choice = response.choices.first, let message = choice.message.content else {
                    DispatchQueue.main.async {
                        completion(nil) // Return nil if there's no content
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(message) // Return the generated message
                }
            case .failure(let error):
                print("Error generating text: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil) // Handle the error appropriately
                }
            }
        }
    }

}
