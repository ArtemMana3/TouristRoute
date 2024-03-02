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
    @Published var route: MKRoute? // The current route
    @Published var isAnnotationDetailPresented: Bool = false
    
    @Published var isCreateRouteViewPresented: Bool = false
    @Published var selectedNumberOfDays: Int = 1
    @Published var selectDistance: Double = 10 

    var routesBetweenPlennedLocationsInnerArray: [MKRoute?] = []
    @Published var routesBetweenPlennedLocations: [MKRoute?] = []
    @Published var plannedLocations: [[Location]] = [[]]
    
    @Published var showSegmentedControl = false

    var selectedPlaceForRoute: String? {
        didSet {
            let startCondinate = self.initialLocation.coordinate
            if let title = selectedPlaceForRoute,
               let place = places.first(where: { $0.name == title }) {
                calculateRoute(
                    from: startCondinate,
                    to: CLLocationCoordinate2D(latitude: place.location.lat, longitude: place.location.lng),
                    isOnlyOneAttraction: true
                )
            }
        }
    }
    
    func createRoutes() {
        var startCondinate = self.initialLocation.coordinate
        for locations in plannedLocations {
            for location in locations {
                calculateRoute(from: startCondinate, to: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng))
                startCondinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            }
        }
    }
    
    func createRoutes(numberOfDay: Int) {
        let locations = plannedLocations[numberOfDay]
        calculateRoutes(locations: locations)
    }
    
    func fetchAttractionsLocations(latitude: Double, longitude: Double) {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=5000&type=tourist_attraction&keyword=top&key=AIzaSyBioLkNiNlJPNetFNFA1Js1Xp2RIRgpy5k"
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
            fetchAttractionsLocations(latitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude)

        }
        locationService.startUpdatingLocation()
    }
    
    func calculateRoute(from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D, isOnlyOneAttraction: Bool = false) {
         let sourcePlacemark = MKPlacemark(coordinate: startCoordinate)
         let destinationPlacemark = MKPlacemark(coordinate: endCoordinate)

         let directionRequest = MKDirections.Request()
         directionRequest.source = MKMapItem(placemark: sourcePlacemark)
         directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
         directionRequest.transportType = .walking

         let directions = MKDirections(request: directionRequest)
         directions.calculate { [weak self] response, error in
             guard let self = self, let route = response?.routes.first else {
                 print("Error: \(error?.localizedDescription ?? "Failed to find route.")")
                 return
             }
             
             routesBetweenPlennedLocationsInnerArray.append(route)
             let totalCount = plannedLocations.reduce(0) { $0 + $1.count }
             if (routesBetweenPlennedLocationsInnerArray.count == totalCount || isOnlyOneAttraction){
                 DispatchQueue.main.async {
                     self.routesBetweenPlennedLocations = self.routesBetweenPlennedLocationsInnerArray
                     self.routesBetweenPlennedLocationsInnerArray = []
                 }
             }
             
         }
     }
    
    func calculateRoutes(locations: [Location]) {
        for index in 0...locations.count - 2 {
            let startLocation = locations[index]
            let endLocation = locations[index + 1]
            let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: startLocation.lat, longitude: startLocation.lng))
            let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: endLocation.lat, longitude: endLocation.lng))
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(placemark: sourcePlacemark)
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            directionRequest.transportType = .walking
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { [weak self] response, error in
                guard let self = self, let route = response?.routes.first else {
                    print("Error: \(error?.localizedDescription ?? "Failed to find route.")")
                    return
                }
                
                routesBetweenPlennedLocationsInnerArray.append(route)
                if (routesBetweenPlennedLocationsInnerArray.count == locations.count - 1){
                    DispatchQueue.main.async {
                        self.routesBetweenPlennedLocations = self.routesBetweenPlennedLocationsInnerArray
                        self.routesBetweenPlennedLocationsInnerArray = []
                    }
                }
                
            }
        }
     }
}
