//
//  LocalSearchController.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/22/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

class LocalSearchController {
	
	//An asynchronous function that searches for a keyword within an MKCoordinateRegion. The function's completion handler takes an array of returned placemarks as an input argument.
	static func search(
		forKeyword keyword: String,
		within region: MKCoordinateRegion,
		completion: @escaping ([MKPlacemark]) -> Void) {
		
		//Using the input arguments to form a request for the MKLocalSearch.
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = keyword
		request.region = region
		
		//Instantiating an MKLocalSearch class to carry out our request.
		let search = MKLocalSearch(request: request)
		
		//Starting the search...
		search.start { (response, error) in
			
			//If no error is returned...
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			//If we get a response...
			guard let response = response else {
				return
			}
			
			//Generate an array of the placemarks for each map item. Execute the completion handler with the placemark array as an input argument.
			let placemarks = response.mapItems.map {
				$0.placemark
			}
			
			completion(placemarks)
		}
	}
}
