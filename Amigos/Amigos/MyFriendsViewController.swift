//
//  ViewController.swift
//  Amigos
//
//  Created by Marcelo Reina on 15/05/17.
//  Copyright © 2017 Marcelo Reina. All rights reserved.

import UIKit

class MyFriendsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var refresh: UIRefreshControl = UIRefreshControl()
    var listOfPeople: [Person]?
    var peopleTuple: [(String, Int)] = []
    var personServices: PersonServices!
    
    var sectionTitles: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refresh.addTarget(self, action: #selector(MyFriendsViewController.refreshAction), for: .valueChanged)
        tableView.addSubview(refresh)
        
        //Creating sections for each letter
        let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
        //Aqui eu tenho um array de letras que pode ser parsado e pego como string baseado no index
        sectionTitles = currentCollation.sectionTitles as NSArray
        
        let nib = UINib(nibName: "HeaderCell", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TitleTableViewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        personServices = PersonServices(delegate: self)
        personServices.getPeople(ordered: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.clear()
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            editButton.title = "ok"
        } else {
            editButton.title = "editar"
        }
    }
    
    func refreshAction() {
        listOfPeople = []
        peopleTuple = []
        tableView.reloadData()
        ImageCache.shared.clear()
        let peopleServices = PersonServices(delegate: self)
        peopleServices.getPeople(ordered: true)
        
        
    }

}

//MARK:UPDATE DA LISTA
extension MyFriendsViewController: PersonServicesDelegate {
    func didReceivedPeople(people: [Person], peopleByLetter: [(String, Int)]) {
        refresh.endRefreshing()
        listOfPeople = people
        peopleTuple = peopleByLetter
        
        tableView.reloadData()
    }
    
    func failedToGetPeople() {
        refresh.endRefreshing()
        print("error")
    }
}

extension MyFriendsViewController: UITableViewDataSource {
    
    //Setta quantas sessões existem
    func numberOfSections(in tableView: UITableView) -> Int {
        return peopleTuple.count
    }
    
    
    
    //Setta quantas celulas tem na sessão section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        
        return peopleTuple[section].1
    }
    
    //Setta a altura do header da sessão section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    //Setta qual é o header que será usado na sessão section (Evaluar as propriedades do header aqui)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TitleTableViewCell") as! SeparatorTableViewCell
        
        cell.titleLabel.text =  peopleTuple[section].0
        return cell
        
    }
    
 
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var pastLettersSum: Int = 0
        for i in 0..<indexPath.section {
            pastLettersSum += peopleTuple[i].1
        }
        
        let person = listOfPeople![indexPath.row + pastLettersSum]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
        cell.name.text = "\(person.firstName.capitalized) \(person.lastName.capitalized)"
        cell.email.text = person.email
        cell.cell.text = person.cell
        
        cell.profilePicture.image = nil
        cell.profilePicture.alpha = 0
        cell.isSelected = false
        ImageCache.shared.getImage(from: person.profilePicture) { (image) in
            if let image = image {
                cell.profilePicture?.image = image
                UIView.animate(withDuration: 0.3, animations: {
                    cell.profilePicture.alpha = 1
                })
            }
        }
        

        return cell
    }
}

extension MyFriendsViewController: UITableViewDelegate {
    
    //MARK: Display management
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let personCell = cell as? PersonTableViewCell {
            personCell.imageView?.image = nil
        }
        
        if listOfPeople != nil && indexPath.row < listOfPeople!.count {
            let person = listOfPeople![indexPath.row]
            ImageCache.shared.cancelImageDownload(from: person.profilePicture)
        }
    }
    
    //MARK: Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PersonDetailViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PersonDetailViewController
        
        var pastLettersSum: Int = 0
        for i in 0..<(tableView.indexPathForSelectedRow?.section)! {
            pastLettersSum += peopleTuple[i].1
        }
        let person = listOfPeople![(tableView.indexPathForSelectedRow?.row)! + pastLettersSum]
        
        destinationVC.contact = person
    }
    
    //MARK: Replace management
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let from = listOfPeople![sourceIndexPath.row]
        let to = listOfPeople![destinationIndexPath.row]
        listOfPeople![destinationIndexPath.row] = from
        listOfPeople![sourceIndexPath.row] = to
    }
    
    //MARK: Edit actions (remove)
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listOfPeople?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //Parte do indexer
    public func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        print("sectionIndexTitlesForTableView")
        var letters: [String] = []
        for i in 0 ..< sectionTitles.count{
            letters.append(String(describing: sectionTitles[i]))
        }
        print(letters.count)
        return letters
        
    }
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        print("sectionForSectionIndexTitle")
        
        var letters: [String] = []
        
        for i in 0 ..< sectionTitles.count{
            letters.append(String(describing: sectionTitles[i]))
        }
        print(letters.count)
        return letters.index(of: title)!
        
    }
    
    //MARK: Actions iOS 8
    /*func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sendMail = UITableViewRowAction(style: .normal, title: "Enviar email") { (action, indexPath) in
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.alpha = 0
                UIView.animate(withDuration: 0.3, animations: {
                    cell.alpha = 1.0
                })
            }
        }
        sendMail.backgroundColor = .blue
        
        let call = UITableViewRowAction(style: .normal, title: "Chamar") { (action, indexPath) in
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.alpha = 0.5
                UIView.animate(withDuration: 0.3, animations: {
                    cell.alpha = 1.0
                })
            }
        }
        call.backgroundColor = .purple
        
        return [sendMail, call]
    }*/
    

}

