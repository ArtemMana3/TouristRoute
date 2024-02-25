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
                    isAnnotationDetailPresented: $vm.isAnnotationDetailPresented,
                    routesBetweenPlennedLocations: $vm.routesBetweenPlennedLocations,
                    isCreateRouteViewPresented: $vm.isCreateRouteViewPresented,
                    showSegmentedControl: $vm.showSegmentedControl, 
                    changeSegment: {
                        vm.isCreateRouteViewPresented = false
                        vm.createRoutes(numberOfDay: $0)
                    }
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
        .sheet(isPresented: $vm.isCreateRouteViewPresented) {
            CreateRouteView(
                selectedNumberOfDays: $vm.selectedNumberOfDays,
                selectDistance: $vm.selectDistance, 
                createRoutes: {
                    vm.isCreateRouteViewPresented = false
                    vm.createRoutes(numberOfDay: 0)
                    vm.showSegmentedControl = true
                }
            
            )
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
    @Binding var routesBetweenPlennedLocations: [MKRoute?]
    @Binding var isCreateRouteViewPresented: Bool
    @Binding var showSegmentedControl: Bool
    var changeSegment: (Int) -> Void

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
        
        // Implement createRouteButton
        let createRouteButton = UIButton(type: .system)
        createRouteButton.translatesAutoresizingMaskIntoConstraints = false
        createRouteButton.backgroundColor = .systemBlue
        createRouteButton.setTitle("Create route", for: .normal)
        createRouteButton.setTitleColor(.white, for: .normal)
        createRouteButton.layer.cornerRadius = 8
        mapView.addSubview(createRouteButton)

        NSLayoutConstraint.activate([
            createRouteButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            createRouteButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            createRouteButton.widthAnchor.constraint(equalToConstant: 150),
            createRouteButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        createRouteButton.addTarget(context.coordinator, action: #selector(Coordinator.createRouteTapped), for: .touchUpInside)
        
        // Implement cleanRouteButton
        let cleanRouteButton = UIButton(type: .system)
        cleanRouteButton.translatesAutoresizingMaskIntoConstraints = false
        cleanRouteButton.backgroundColor = .systemBlue
        cleanRouteButton.setTitle("Clean", for: .normal)
        cleanRouteButton.setTitleColor(.white, for: .normal)
        cleanRouteButton.layer.cornerRadius = 8
        mapView.addSubview(cleanRouteButton)

        NSLayoutConstraint.activate([
            cleanRouteButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 20),
            cleanRouteButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20),
            cleanRouteButton.widthAnchor.constraint(equalToConstant: 50),
            cleanRouteButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        cleanRouteButton.addTarget(context.coordinator, action: #selector(Coordinator.cleanRouteTapped), for: .touchUpInside)

        // UISegmentedControl setup
         let segmentedControl = UISegmentedControl(items: ["Option 1", "Option 2"])
         segmentedControl.translatesAutoresizingMaskIntoConstraints = false
         segmentedControl.selectedSegmentIndex = 0
         segmentedControl.isHidden = true // Initially hidden
         mapView.addSubview(segmentedControl)
         
         // UISegmentedControl Auto Layout
         NSLayoutConstraint.activate([
             segmentedControl.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
             segmentedControl.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
             segmentedControl.widthAnchor.constraint(equalToConstant: 200),
             segmentedControl.heightAnchor.constraint(equalToConstant: 30)
         ])
         
        segmentedControl.addTarget(context.coordinator, action: #selector(Coordinator.segmentChanged(_:)), for: .valueChanged)

         // Storing references in the Coordinator
         context.coordinator.createRouteButton = createRouteButton
         context.coordinator.segmentedControl = segmentedControl
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        
        context.coordinator.createRouteButton?.isHidden = showSegmentedControl
        context.coordinator.segmentedControl?.isHidden = !showSegmentedControl
        
        for route in routesBetweenPlennedLocations {
            if let route = route {
                uiView.addOverlay(route.polyline, level: .aboveRoads)
                
                // Check if the route has changed since last update
                if routesBetweenPlennedLocations != context.coordinator.lastRoute {
                    let padding = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
                    uiView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: padding, animated: true)
                    
                    context.coordinator.lastRoute = routesBetweenPlennedLocations
                }
            }
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        var lastRoute: [MKRoute?]? // Track the last route used for setting the visible region
        
        var createRouteButton: UIButton?
        var segmentedControl: UISegmentedControl?
        
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
        
        @objc func createRouteTapped() {
            self.parent.isCreateRouteViewPresented = true
        }
        
        @objc func cleanRouteTapped() {
            self.parent.routesBetweenPlennedLocations = []
            self.parent.showSegmentedControl = false
        }
        
        @objc func segmentChanged(_ sender: UISegmentedControl) {
            createRouteTapped()
            self.parent.changeSegment(sender.selectedSegmentIndex)
            let selectedIndex = sender.selectedSegmentIndex
            print("Selected segment index: \(selectedIndex)")
        }
    }
}

struct MapLocal_Previews: PreviewProvider {
    static var previews: some View {
        MapLocal()
    }
}
