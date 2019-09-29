//
//  Disposable+Extensions.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

// The disposable is initialized with a callback that is executed on its deinit. Typically, the disposable return from the addObserver() function is referenced solely in the observer itself so that when the observer de-initializes, so does the disposable. This removes up any observations that would otherwise be trying to notify an observer that is no longer in memory.
class Disposable {
	let dispose: () -> Void
	init(dispose: @escaping () -> Void) { self.dispose = dispose }
	deinit {
		dispose()
	}
}

//Often the observer will have multiple active observations. A DisposeBag is a handy way to store all of the disposables returned by each observation. When an observer de-initializes so does its dispose bag, which calls the dispose() function of every dispose-bag stored disposable.
class DisposeBag {
	private var disposables: [Disposable] = []
	func insert(_ disposable: Disposable) {
		disposables.append(disposable)
	}
}

//A helper function for adding disposables to a dispose bag.
extension Disposable {
	func disposed(by bag: DisposeBag) {
		bag.insert(self)
	}
}
