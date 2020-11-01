//
//  ContentView.swift
//  LocationUpdata
//
//  Created by hiroshi yamato on 2020/11/01.
//

import SwiftUI
import MapKit
//import CoreLocation

struct ContentView: View {
    @State var latitude: String = "not available"
    @State var longitude: String = "not available"
    
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    

    var body: some View {
                
        VStack{

            HStack {
                Text("Latitude:")
                Text(latitude)

            }
            HStack {
                Text("longitude:")
                Text(longitude)
            }
            Button(action: {
                print("Button Tapped")
                latitude = managerDelegate.latitude
                longitude = managerDelegate.longitude
            }){
                Text("Current Location")
            }
        }
        .onAppear() {
            manager.delegate = managerDelegate
            manager.requestWhenInUseAuthorization()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// CLLocatoinManagerDelegate
class locationDelegate : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: String = "none"
    @Published var longitude: String = "none"
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        if manager.authorizationStatus == .authorizedWhenInUse {
            print("authorized")
            
            manager.startUpdatingLocation()

            // add "Privacy - Location Default Accuracy Reduced" in info.plist
            // and edit in souce code that value is <true/>
            if manager.accuracyAuthorization != .fullAccuracy {
                print("reduce accuracy")

                // add "Privacy - Location Temporary Usage Description Dictionary" in info.plist
                // and set "Location" in Key
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Location") {
                    (err) in
                    if err != nil {
                        print(err!)
                        return
                    }
                }
            }
        } else {
            print("not authorized")
            // add "Privacy - Location When In Use Usage Description" in info.plist
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(String(format: "%+.06f", location.coordinate.latitude))
            print(String(format: "%+.06f", location.coordinate.longitude))
            
            latitude = String(format: "%+.06f", location.coordinate.latitude)
            longitude = String(format: "%+.06f", location.coordinate.longitude)
            
        }
    }

}
