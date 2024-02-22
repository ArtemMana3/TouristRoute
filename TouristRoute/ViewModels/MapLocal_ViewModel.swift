//
//  MapLocal_ViewModel.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 28.05.2023.
//

import Foundation
import MapKit

class MapLocalViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var initialLocation = CLLocation(latitude: 50.4501, longitude: 30.5234)
    private let locationService = LocationService()
    @Published var selectedPlaceTitle: String? = nil

    func fetchBankLocations(latitude: Double, longitude: Double) {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=9000&type=tourist_attraction&keyword=top&key=AIzaSyBioLkNiNlJPNetFNFA1Js1Xp2RIRgpy5k"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let results = try JSONDecoder().decode(APIResponse.self, from: data)
                let places = results.results.map { result -> Place in
                      // Assuming you want to capture the first photo reference if available
                    let firstPhotoReference = result.photos.first?.photo_reference
                    return Place(name: result.name, latitude: result.geometry.location.lat, longitude: result.geometry.location.lng, photoReference: firstPhotoReference ?? "")
                }
                
                DispatchQueue.main.async {
                    self.places = places
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func updateLocation() {
        locationService.onLocationUpdate = { [self] location in
            initialLocation = location
            fetchBankLocations(latitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude)

        }
        locationService.startUpdatingLocation()
    }
}
