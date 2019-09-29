//
//  ObservingCell.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

//ObservingCell conforms to the observer protocol
class ObservingCell: UITableViewCell, Observer {
	
	//A dispose bag to store the cell's disposables
	var disposeBag = DisposeBag()

	//In the prepareForReuse() method we will remove all observations. Otherwise, cells accrue observations every time they are reused.
	override func prepareForReuse() {
		super.prepareForReuse()
		removeAllObservations()
	}
}
