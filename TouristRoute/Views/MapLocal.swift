//
//  Map.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 15.04.2023.
//

import SwiftUI
import MapKit

struct MapLocal: View {
    @StateObject var vm = MapLocalViewModel()
    var body: some View {
        VStack {
            if !vm.places.isEmpty {
                MapView(initialLocation: vm.initialLocation, places: vm.places, selectedPlaceTitle: $vm.selectedPlaceTitle)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            vm.updateLocation()
        }
        .sheet(item: $vm.selectedPlaceTitle) { title in
            let place = vm.places.first(where: { $0.name == title })
            
            if let place = place {
                let photoReference = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1500&photoreference=\(place.photoReference)&key=AIzaSyBioLkNiNlJPNetFNFA1Js1Xp2RIRgpy5k"
                AnnotationDetailView(title: title, imageUrl: URL(string: photoReference)!)
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    let regionRadius: CLLocationDistance = 600
    var initialLocation: CLLocation
    let places: [Place]
    @Binding var selectedPlaceTitle: String?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        for i in 0..<places.count {
            let location = places[i].location
            let name = places[i].name
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.asCLLocation.coordinate
            annotation.title = name
            mapView.addAnnotation(annotation)
        }
        
        let button = MKUserTrackingButton(mapView: mapView)
        mapView.addSubview(button)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = UIColor.red
                renderer.fillColor = UIColor.red.withAlphaComponent(0.3)
                return renderer
            } else {
                return MKOverlayRenderer(overlay: overlay)
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                DispatchQueue.main.async {
                    self.parent.selectedPlaceTitle = annotation.title ?? ""
                    
                }
            }
        }
    }
}

struct MapLocal_Previews: PreviewProvider {
    static var previews: some View {
        MapLocal()
    }
}
