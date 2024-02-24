//
//  CreateRouteView.swift
//  TouristRoute
//
//  Created by Artem Manakov on 24.02.2024.
//

import Foundation
import SwiftUI

struct CreateRouteView: View {
    @Binding var selectedNumberOfDays: Int
    @Binding var selectDistance: Double
    var createRoutes: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            
            VStack {
                // Segmented Control for selecting a number
                Text("Select how many day are you going to stay")
                Picker("Select a number", selection: $selectedNumberOfDays) {
                    ForEach(1...7, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Display the selected number
                Text("Selected number: \(selectedNumberOfDays)")
                
                // Divider
                Divider()
                    .padding()
                
                // Slider for selecting distance
                VStack(alignment: .leading) {
                    Text("How many kilometers can you go per day?")
                        .font(.headline)
                    
                    Slider(value: $selectDistance, in: 5...20, step: 1)
                    Text("\(String(format: "%.0f", selectDistance)) km")
                }
                .padding()
                
                Button("Create route") {
                    createRoutes()
                    presentationMode.wrappedValue.dismiss()
                    print("Creating route with number: \(selectedNumberOfDays) and distance: \(selectDistance) km")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                
                Spacer()
            }
            .navigationTitle("Create route")
        }
    }
}
