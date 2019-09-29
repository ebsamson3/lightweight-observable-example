//
//  FormatDisplay.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/22/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

struct FormatDisplay {
	
    static func distance(_ distance: Double) -> String {
		
		let distanceMeasurement = Measurement(
			value: distance,
			unit: UnitLength.meters)

		return FormatDisplay.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
		
        let measurementFormatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        measurementFormatter.numberFormatter = numberFormatter
		
		return measurementFormatter.string(from: distance)
    }
}
