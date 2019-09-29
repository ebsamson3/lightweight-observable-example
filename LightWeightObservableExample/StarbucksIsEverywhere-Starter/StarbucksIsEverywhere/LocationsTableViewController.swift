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
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		return tableView
	}()
	
	private lazy var activityIndicator: UIActivityIndicatorView  = {
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.style = .large
		activityIndicator.color = .starbucksGreen
		activityIndicator.hidesWhenStopped = true
		return activityIndicator
	}()
	
	let locationController: LocationController
	
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
}

extension LocationsTableViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
}

extension LocationsTableViewController: UITableViewDelegate {}

