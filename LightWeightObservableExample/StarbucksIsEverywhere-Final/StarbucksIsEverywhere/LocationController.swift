//
//  LocationController.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

class LocationController: NSObject {
	
	//Initialization of our observable. The observable's stored value is an optional CLLocation with an initial value of nil.
	private var _location = Observable<CLLocation?>(nil)

	//Since the LocationController will handling all _location value changes, we want to make our observable's value get only. Additionally, making access to our observable through the location property is much cleaner than having to type _location.value.
	var location: CLLocation? {
		get {
			return _location.value
		}
	}

	//Creating a CLLocationManager that will update our app with the current device location. A minimum of distance of 10 meters is required to be traversed for a location update.
	private lazy var locationManager: CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.distanceFilter = 10
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		return locationManager
	}()

	//When the LocationController is initialized we begin monitoring device location. This occurs just before setting the main app window's rootController in scene(willConnectTo:).
	override init() {
		super.init()
		locationManager.startUpdatingLocation()
	}
	
	//A function to add an observer to our current location.
	func addLocationObserver(
		_ observer: Observer,
		options: ObservableOptions,
		didChange: @escaping  Observable<CLLocation?>.ChangeHandler)
	{
		observer.observe(
			_location,
			options: options,
			didChange: didChange)
	}

	//A function to remove a current location observer.
	func removeLocationObserver(_ observer: Observer) {
		_location.removeObserver(observer)
	}
}

//Here we add an extension that conforms the LocationController to the CLLocationManagerDelegate protocol. When the location manager delegate method locationManager(didUpdateLocations:) is called the observable's value is set to value the first location in the locations array.
extension LocationController: CLLocationManagerDelegate {
	func locationManager(
		_ manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation])
	{
		if let location = locations.last {
			_location.value = location
		}
	}
}


