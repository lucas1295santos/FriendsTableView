//
//  PeopleServices.swift
//  Amigos
//
//  Created by Marcelo Reina on 15/05/17.
//  Copyright © 2017 Marcelo Reina. All rights reserved.
//

import UIKit

/// Responsibilities for the one who uses `PersonServices`
protocol PersonServicesDelegate: NSObjectProtocol {
    /// Received array of person from somewhere
    ///
    /// - Parameter people: array of `Person`
    /// - Parameter peopleByLetter: dictionary
    func didReceivedPeople(people: [Person], peopleByLetter: [(String, Int)])
    
    /// Called when it was unable to retrieve people data
    func failedToGetPeople()
}



/// Person provider.
/// It performs asynchronous tasks and requires a delegate to manage received data
class PersonServices: NSObject {
    
    fileprivate var delegate: PersonServicesDelegate!
    
    //MARK: Initialization
    fileprivate override init() {}
    
    /// init that sets the delegate to avoid
    ///
    /// - Parameter delegate: instance that conforms to PeopleServicesDelegate and is responsible for managing the responses of PeopleServices
    init(delegate: PersonServicesDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    
    /// Get people asynchronously and calls the delegate when it receives the list of people
    ///
    /// - Parameter ordered: if the list of person should be ordered by names.
    func getPeople(ordered: Bool) {
        delayedGetPeople(ordered: true, delayInSeconds: 4.0)
    }
    
    /// Waits 'delayInSeconds' to get the list of people and call the delegate methods. This method simulates a asynchronous operation by schedulling the operation in a timer. This aproach should not be user in real projects!
    ///
    /// - Parameters:
    ///   - ordered: if the list of person should be ordered by names.
    ///   - delayInSeconds: time in seconds that the function will wait before performing the task.
    fileprivate func delayedGetPeople(ordered: Bool, delayInSeconds: TimeInterval) {
        Timer.scheduledTimer(withTimeInterval: delayInSeconds, repeats: false) { (timer) in
            if var listOfPeople = PersonFileStorage.loadPeopleFromFile() {
                if ordered {
                    listOfPeople = listOfPeople.sorted(by: { (oneElement, otherElement) -> Bool in
                        return oneElement.firstName.compare(otherElement.firstName) == .orderedAscending
                    })
                }
                //Create the touple based on the list of people
                var touple = [(String, Int)]()
                let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
                let sectionTitles = currentCollation.sectionTitles as NSArray
                
                
                
                
            
                
                    var sectionIndex = 0
                
                    //Iterating througth the list
                    for _ in sectionTitles {
                        
                        let strKey = String(describing: sectionTitles[sectionIndex])    //The string key i'm analysing now
                        
                        //Predicate is the filter parameter for filtering the array
                        let namePredicate = NSPredicate(format:"SELF beginswith[cd] %@", strKey)
                        //This filters the array using the predicate
                        let filtered = listOfPeople.filter() {
                            return namePredicate.evaluate(with: $0.firstName)
                        }
                        
                        touple.append((strKey, filtered.count))
                        sectionIndex += 1
                    }
                
                //Call the delegate passing the list and the touple
                self.delegate.didReceivedPeople(people: listOfPeople, peopleByLetter: touple)
                
            } else {
                self.delegate.failedToGetPeople()
            }
            timer.invalidate()
        }
    }

}
