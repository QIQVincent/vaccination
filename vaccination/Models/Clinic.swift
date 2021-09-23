//
//  Clinic.swift
//  vaccination
//
//  Created by User on 20/9/21.
//

import Foundation
import CoreLocation

struct Clinic: Identifiable {
    var id: String
    var vaccineType: String
    var name: String
    var address: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var distance: Double
    var hours: String
}
