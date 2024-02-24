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
                MapView(
                    initialLocation: vm.initialLocation,
                    places: vm.places,
                    selectedPlaceTitle: $vm.selectedPlaceTitle,
                    route: $vm.route,
                    isAnnotationDetailPresented: $vm.isAnnotationDetailPresented
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            vm.updateLocation()
        }
        .sheet(isPresented: $vm.isAnnotationDetailPresented) {
            let place = vm.places.first(where: { $0.name == vm.selectedPlaceTitle })
            
            if let place = place {
                let photoReference = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1500&photoreference=\(place.photoReference)&key=AIzaSyBioLkNiNlJPNetFNFA1Js1Xp2RIRgpy5k"
                
                AnnotationDetailView(
                    title: vm.selectedPlaceTitle ?? "",
                    imageUrl: URL(string: photoReference)!,
                    onRouteSelect: { selectedTitle in
                        vm.selectedPlaceForRoute = selectedTitle
                        vm.isAnnotationDetailPresented = false
                     }
                )
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    let regionRadius: CLLocationDistance = 600
    var initialLocation: CLLocation
    let places: [Place]
    @Binding var selectedPlaceTitle: String?
    @Binding var route: MKRoute?
    @Binding var isAnnotationDetailPresented: Bool
    
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
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        
        if let route = self.route {
            uiView.addOverlay(route.polyline, level: .aboveRoads)

            // Check if the route has changed since last update
            if route != context.coordinator.lastRoute {
                let padding = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
                uiView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: padding, animated: true)

                context.coordinator.lastRoute = route
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        var lastRoute: MKRoute? // Track the last route used for setting the visible region

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4.0
                return renderer
            } else if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = UIColor.red
                renderer.fillColor = UIColor.red.withAlphaComponent(0.3)
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                DispatchQueue.main.async {
                    self.parent.selectedPlaceTitle = annotation.title ?? ""
                    self.parent.isAnnotationDetailPresented = true
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
