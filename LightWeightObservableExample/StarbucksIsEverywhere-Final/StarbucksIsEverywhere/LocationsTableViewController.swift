//
//  LocationsTableViewController.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import MapKit

class LocationsTableViewController: UIViewController {
	
	//Add a dispose bag to conform our LocationTableViewController to the Observer protocol. This is where we'll stick the disposable that is returned when we add the LocationTableViewController as a location observer.
	var disposeBag = DisposeBag()
	
	//A variable to track whether or not we've loaded the initial location from the location manager.
	var isLoaded = false
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		return tableView
	}()
	
	//We lazy load our refresh control, because we will need access to self in order to add an action to it.
	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()

		//Look in the UIColor+Extensions.swift file to see the declaration for the custom color .starbucksGreen.
		refreshControl.tintColor = .starbucksGreen

		//We add an action that will be triggered by our pull to refresh control. This calls #selector(handleTableRefresh(sender:)). Let's code that next...
		refreshControl.addTarget(
			self,
			action: #selector(handleTableRefresh(sender:)),
			for: .valueChanged)

		return refreshControl
	}()
	
	private lazy var activityIndicator: UIActivityIndicatorView  = {
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.style = .large
		activityIndicator.color = .starbucksGreen
		activityIndicator.hidesWhenStopped = true
		return activityIndicator
	}()
	
	let locationController: LocationController
	var placemarks = [MKPlacemark]()
	
	init(locationController: LocationController) {
		self.locationController = locationController
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		generatePlacemarksWhenReady()

		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
		}
	}
	
	func configure() {
		view.addSubview(tableView)
		view.addSubview(activityIndicator)
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		
		tableView.topAnchor.constraint(
			equalTo: view.topAnchor)
			.isActive = true

		tableView.leadingAnchor.constraint(
			equalTo: view.leadingAnchor)
			.isActive = true

		tableView.bottomAnchor.constraint(
			equalTo: view.bottomAnchor)
			.isActive = true

		tableView.trailingAnchor.constraint(
			equalTo: view.trailingAnchor)
			.isActive = true
		
		activityIndicator.centerXAnchor.constraint(
			equalTo: tableView.centerXAnchor)
			.isActive = true
		
		activityIndicator.centerYAnchor.constraint(
			equalTo: tableView.centerYAnchor)
			.isActive = true
	}
	
	@objc func handleTableRefresh(sender: UIRefreshControl) {
		guard let location = locationController.location else {
			return
		}
		loadPlacemarks(near: location) { [weak self] placemarks in
			DispatchQueue.main.async {
				self?.refreshControl.endRefreshing()
				self?.insertPlacemarks(placemarks)
			}
		}
	}
}

extension LocationsTableViewController: UITableViewDataSource {
	
	//Set the number of cells equal to the number of placemarks returned by our local search.
	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int) -> Int
	{
		return placemarks.count
	}

	//Dequeue an observing cell if any exist. Otherwise create a new cell instance. Then configure the cell before returning it. 
	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let reuseIdentifier = "ObservingCell"
		let cell: ObservingCell

		if let dequeuedCell = tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier) as? ObservingCell
		{
			cell = dequeuedCell
		} else {
			cell = ObservingCell(
				style: .subtitle,
				reuseIdentifier: reuseIdentifier)
		}

		configure(cell, atIndexPath: indexPath)

		return cell
	}
	
	func configure(
		_ observingCell: ObservingCell,
		atIndexPath indexPath: IndexPath) {

		let row = indexPath.row
		let placemark = placemarks[row]

		//Set the text label of the observing cell to the placemarks street address. I've defined getAddressString() in a CLPlacemark+Extensions.swift.
		observingCell.textLabel?.text = placemark.getAddressString()

		//Add the cell as an observer to the current location. Specify the option [.initial] because we want to handle the current value of the observable immediately after binding.
		locationController.addLocationObserver(
			observingCell,
			options: [.initial]) { [weak observingCell] (location, _) in

				//If the current location and placemark location are both non-nil proceed. Otherwise set the distance string to "N/A".
				guard
					let location = location,
					let placemarkLocation = placemark.location
				else {
					observingCell?.detailTextLabel?.text = "N/A"
					return
				}

				//Calculate the distance between the two the placemark location and your current location.
				let distance = placemarkLocation.distance(from: location)
				
				//In utilities, I've created .a struct named FormatDisplay that contains the function used to convert distance in meters to a string.
				let distanceString = FormatDisplay.distance(distance)

				//Set the detail text label to the distance string.
				observingCell?.detailTextLabel?.text = distanceString
		}
	}
}

extension LocationsTableViewController: UITableViewDelegate {}

extension LocationsTableViewController: Observer {
	
	//Generate placemarks once the app is ready, where ready is when the LocationTableViewController has observed the first non-nil location. For now, let's just make sure we can observe and print the our current location.
	func generatePlacemarksWhenReady() {
		
		//Add the LocationTableViewController as an observer. Specify the option [.initial] because we want to handle the current value of the observable immediately after binding. We use an escaping closure to handle what we do with the location once notified by the observable.
		locationController.addLocationObserver(
			self,
			options: [.initial]) { [weak self] (location, _) in
				
				guard let strongSelf = self else {
					return
				}
				
				//We only want to observe the location until we receive the first non-nil location. If isLoaded == true we should unsubscribe from future notifications and return from the closure.
				guard strongSelf.isLoaded == false
					
					else {
						self?.locationController.removeLocationObserver(strongSelf)
						return
				}
				
				//If the location is not nil, proceed. Otherwise, return.
				guard let location = location else {
					return
				}
				
				//Print the location and set the isLoaded status to true so that the next time LocationTableViewController notified by the location we will just return from the closure and remove it from further observations.
				strongSelf.isLoaded = true
				
				//Start activity indicator prior to querying for placemarks
				strongSelf.activityIndicator.startAnimating()

				//Async function to load placemarks.
				strongSelf.loadPlacemarks(near: location) { placemarks in
					
					//After loading the placemarks we insert them into the tableView.
					DispatchQueue.main.async {
						strongSelf.activityIndicator.stopAnimating()
						strongSelf.insertPlacemarks(placemarks)
					}
				}
		}
	}
	
	//An async function to load placemarks.
	func loadPlacemarks(
		near location: CLLocation,
		completion: @escaping ([MKPlacemark]) -> Void)
	{
		
		//Defining the MKCoordinateRegion where our search will be performed.
		let center = location.coordinate
		let regionSideLength: CLLocationDistance = 10000
		let region = MKCoordinateRegion(
			center: center,
			latitudinalMeters: regionSideLength,
			longitudinalMeters: regionSideLength)
		
		//Calling the static search function in LocalSearchController. If you'd like to search for locations other than Starbucks, you can do so by changing the forKeyword: argument.
		LocalSearchController.search(
			forKeyword: "Starbucks",
			within: region,
			completion: completion)
	}

	//A function to display the placemarks after you've loaded them. I use reloadSections() instead of reloadData() to update the table because it has a nice animation associated with it.
	func insertPlacemarks(_ newPlacemarks: [MKPlacemark]) {
		placemarks = newPlacemarks
		tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
	}
	
}

