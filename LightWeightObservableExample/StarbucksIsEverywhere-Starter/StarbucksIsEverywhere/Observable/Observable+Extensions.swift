//
//  Observable.swift
//  ObserverExample
//
//  Created by Edward Samson on 9/21/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit


class Observable<T> {
	//We use a type alias for the type of function that executes upon a change in the observable value. This helps make the rest of our observable code a little less verbose.
	typealias ChangeHandler = ((_ new: T, _ old: T?) -> Void)
	
	//The value stored inside our observable. When it is updated it triggers a didSet to notify all observers. We use a generic class so that this value can be of any type.
	var value: T {
		didSet {
			notifyAllObservers(oldValue: oldValue)
		}
	}
	
	//A dictionary of closures that execute when the observable value is updated. Each closure takes the old and new value of the observable as input arguments. The closures are keyed by the object identifier of the corresponding observer. By keying them with the identifier of the observer itself, the observer now has a convenient way to remove its callback from the observers array.
	fileprivate var observers = [ObjectIdentifier: ChangeHandler]()
	
	init(_ value: T) {
		self.value = value
	}
	
	//Notifying all observers essentially amounts to executing the callback function for each active observer.
	func notifyAllObservers(oldValue: T?) {
		for observer in observers.values {
			observer(value, oldValue)
		}
	}
}

extension Observable {
	//Adding observers to the observable. The input arguments are the observer, any number of specified options, and a change handling closure that executes when the observer updates its value.
	func addObserver(
		_ observer: AnyObject,
		options: ObservableOptions = [],
		didChange: @escaping ChangeHandler) -> Disposable
	{
		
		let objectIdentifier = ObjectIdentifier(observer)
		observers[objectIdentifier] = didChange
		
		//Options are handled each team the change handler is called.
		if options.contains(.initial) {
			didChange(value, nil)
		}
		
		//After adding an observer to the observers array, we return a disposable that acts as an eventual way to remove that observer. This ensures that any observer that subscribes to notifications has a reliable way to unsubscribe.
		return Disposable { [weak self] in
			self?.removeObserver(observer)
		}
	}
	
	//Removing an observer from the observers array stops it from receiving further value change notifications. This function is called simply by placing the observer as the input argument. The convenience of keying the observers dictionary with object identifiers is that we don’t have to store any specific UUID or tag in order to unsubscribe.
	func removeObserver(_ observer: AnyObject) {
		let objectIdentifier = ObjectIdentifier(observer)
		observers.removeValue(forKey: objectIdentifier)
	}
}

extension Observable: CustomStringConvertible {
	var description: String {
		return "\(value)"
	}
}

//Here is where observable options are defined. I've added a comment which shows how to add a second option if you find you need to further tune your observations. Any option you add have needs to be implemented in the addObserver() function
struct ObservableOptions: OptionSet {
	let rawValue: Int
	static let initial = ObservableOptions(rawValue: 1 << 0)
	//static let secondOption  = ObservableOptions(rawValue: 1 << 1)
}

final class CoalescingObservable<T: Equatable>: Observable<T> {
	
	override func notifyAllObservers(oldValue: T?) {
		guard oldValue != value else { return }
		for observer in observers.values {
			observer(value, oldValue)
		}
	}
}

