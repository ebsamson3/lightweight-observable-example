//
//  Observer.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

//AAn observer should hold a reference to a dispose bag.
protocol Observer: class {
	var disposeBag: DisposeBag { get set }
}

extension Observer {
	
	//Since the protocol guarantees our observer will have a dispose bag, it is convenient to have a function that subscribes to an observation and sticks the returned disposable in the dispose bag.
	func observe<T>(
		_ observable: Observable<T>,
		options: ObservableOptions = [],
		didChange: @escaping Observable<T>.ChangeHandler) {
		
		observable.addObserver(self, options: options, didChange: didChange)
			.disposed(by: disposeBag)
	}
	
	//The observer can remove all its current observations by replacing its reference to its current dispose bag with a reference to a new dispose bag.
	func removeAllObservations() {
		disposeBag = DisposeBag()
	}
}
