//
//  CLPlacemark+Extensions.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

extension CLPlacemark {
	
	func getAddressString() -> String {
		
		let space =
			(subThoroughfare != nil && thoroughfare != nil) ? " " : ""
		
		let addressString = String(
			format: "%@%@%@",
			subThoroughfare ?? "",
			space,
			thoroughfare ?? ""
		)
		
		return addressString
	}
}
