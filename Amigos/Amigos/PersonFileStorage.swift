//
//  PeopleStorage.swift
//  Amigos
//
//  Created by Marcelo Reina on 15/05/17.
//  Copyright © 2017 Marcelo Reina. All rights reserved.
//

import Foundation

class PersonFileStorage {
    
    //MARK: Constants
    static fileprivate let fileName = "people"
    static fileprivate let fileExtension = "JSON"
    
    
    /// Load people.JSON file and parse the information to return a `Person` array.
    ///
    /// - Returns: Person array or nil if it was unable to load or parse.
    class func loadPeopleFromFile() -> [Person]? {
        
        // Get file url from main bundle
        let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        guard url != nil else {
            return nil
        }
        
        // Load data from file url
        let data = try? Data(contentsOf: url!)
        guard data != nil else {
            return nil
        }
        
        // Convert Data to JSON
        let rawJson = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        guard rawJson != nil else {
            return nil
        }
        
        
        let json = rawJson as? [String: Any]
        guard json != nil else {
            return nil
        }
        
        // parse people
        return PersonFileStorage.parsePeople(json: json!)
    }
    
    //MARK: JSON parser functions
    class fileprivate func parsePeople(json: [String: Any]) -> [Person]? {
        
        let results = json["results"] as? [[String: Any]]
        guard results != nil else {
            return nil
        }
        
        var personArray = [Person]()
        for personJSON in results! {
            if let person = parsePerson(json: personJSON) {
                personArray.append(person)
            }
        }
        
        return personArray
    }
    
    class fileprivate func parsePerson(json: [String: Any]) -> Person? {
        
        let addressJSON = json["location"] as? [String: Any]
        guard addressJSON != nil else {
            return nil
        }
        
        let address = parseAddress(json: addressJSON!)
        guard address != nil else {
            return nil
        }
        
        let name = json["name"] as? [String: Any]
        guard name != nil else {
            return nil
        }
        
        let firstName = name!["first"] as? String
        guard firstName != nil else {
            return nil
        }
        
        let lastName = name!["last"] as? String
        guard lastName != nil else {
            return nil
        }
        
        let title = name!["title"] as? String
        guard title != nil else {
            return nil
        }
        
        let email = json["email"] as? String
        guard email != nil else {
            return nil
        }
        
        let phone = json["phone"] as? String
        guard phone != nil else {
            return nil
        }
        
        let cell = json["cell"] as? String
        guard cell != nil else {
            return nil
        }
        
        let picture = json["picture"] as? [String:Any]
        guard picture != nil else {
            return nil
        }
        
        let profilePictureString = picture!["large"] as? String
        guard profilePictureString != nil else {
            return nil
        }
        
        let profilePicture = URL(string: profilePictureString!)
        guard profilePicture != nil else {
            return nil
        }
        
        return Person(title: title!,
                      firstName: firstName!,
                      lastName: lastName!,
                      email: email!,
                      phone: phone!,
                      cell: cell!,
                      address: address!,
                      profilePicture: profilePicture!)
    }
    
    class fileprivate func parseAddress(json: [String: Any]) -> Address? {
        
        let street = json["street"] as? String
        guard street != nil else {
            return nil
        }
        
        let city = json["city"] as? String
        guard city != nil else {
            return nil
        }
        
        let state = json["state"] as? String
        guard state != nil else {
            return nil
        }
        
        let postCode = json["postcode"] as? Int64
        guard postCode != nil else {
            return nil
        }
        
        return Address(street: street!,
                       city: city!,
                       state: state!,
                       postCode: postCode!)
    }
    
}
