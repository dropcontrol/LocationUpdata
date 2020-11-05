//
//  ContentView.swift
//  LocationUpdata
//
//  Created by hiroshi yamato on 2020/11/01.
//

import SwiftUI
import MapKit

// @ObservableObjectの場合
// 複数のViewを跨ることができる。
class PlaceInfo: ObservableObject {
    @Published var latitude: String = "none"
    @Published var longitude: String = "none"
}

struct ContentView: View {
// @Stateの場合。
// 単一Viewでの操作
//    @State var latitude: String = "not available"
//    @State var longitude: String = "not available"
    
    @ObservedObject var placeInfo = PlaceInfo()
    
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    

    var body: some View {
        
        
        VStack{

            HStack {
                Text("Latitude:")
                Text(placeInfo.latitude)
//                Text(latitude)　// @state
            }
            HStack {
                Text("longitude:")
                Text(placeInfo.longitude)
//                Text(longitude) // @state
            }
            Button(action: {
                print("Button Tapped")
                
                placeInfo.latitude = managerDelegate.currentLatitude
                placeInfo.longitude = managerDelegate.currentLongitude
//                latitude = managerDelegate.currentLatitude @state
//                longitude = managerDelegate.currentLongitude @state
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
    
    // delegateから取り出すための@Pubishedな変数
    @Published var currentLatitude: String = "none"
    @Published var currentLongitude: String = "none"
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        if manager.authorizationStatus == .authorizedWhenInUse {
            print("authorized")
            
            manager.startUpdatingLocation()

            // add "Privacy - Location Default Accuracy Reduced" in info.plist
            // and edit in souce code that value is <true/> or <false/>
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
            
            currentLatitude = String(format: "%+.06f", location.coordinate.latitude)
            currentLongitude = String(format: "%+.06f", location.coordinate.longitude)
            
        }
    }

}
