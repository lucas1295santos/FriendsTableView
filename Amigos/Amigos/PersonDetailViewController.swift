//
//  PersonDetailViewController.swift
//  Amigos
//
//  Created by Marcelo Reina on 16/05/17.
//  Copyright © 2017 Marcelo Reina. All rights reserved.
//

import UIKit

class PersonDetailViewController: UIViewController {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    public var contact: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactImage.layer.cornerRadius = contactImage.frame.size.width/2
        contactImage.clipsToBounds = true
        
        if (contact != nil){
            contactNameLabel.text = ("\(String(describing: (contact?.firstName)!)) \(String(describing: (contact?.lastName)!))")
            
            
            contactImage.image = nil
            contactImage.alpha = 0
            ImageCache.shared.getImage(from: (contact?.profilePicture)!) { (image) in
                if let image = image {
                    self.contactImage.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        self.contactImage.alpha = 1
                    })
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
