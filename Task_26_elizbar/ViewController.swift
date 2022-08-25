//
//  ViewController.swift
//  Task_26_elizbar
//
//  Created by alta on 8/26/22.
//

import UIKit

class ViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var segmentIndicator = 0
    @IBOutlet weak var filterSegmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    private var models = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotes()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createnEmptyNote))
    }
// sorting cells by using  UISegmentController
    @IBAction func segmentControllerChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            segmentIndicator = 0
            getNotes()
        }else if sender.selectedSegmentIndex == 1{
            segmentIndicator = 1
            getDataUsingPredicate()
        }
    }
    // sorting data with predicate
    func getDataUsingPredicate() {
        let request = Note.fetchRequest()
    
        let mulutiPredicate = NSPredicate(format: "isFavourite == YES")
        
        request.predicate = mulutiPredicate
        
        let notes = try! context.fetch(request)
        
        self.models = notes
        tableView.reloadData()
    }
    //creting note but only giving title
    @objc func createnEmptyNote(){
        let alert = UIAlertController(title: "add new note",message: "", preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "note name"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
            alert.addAction(UIAlertAction(title: "Create", style: .default,handler: { _ in
                guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else{
                    return
                }
                
                self.createNote(title: text, noteText: "", isFavourite: false)
               
                if self.segmentIndicator == 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.getDataUsingPredicate()
                    }
                }
            }))
            present(alert,animated: true)
        }
    //fetching notes from coreData
    func getNotes(){
        do{
            models = try context.fetch(Note.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            print(error)
        }
    }
    //creating new note
    func createNote(title:String,noteText:String,isFavourite: Bool){
        let newNote = Note(context: context)
        newNote.title = title
        newNote.noteText = noteText
        newNote.isFavourite = isFavourite
        
        do{
            try context.save()
            getNotes()
        }catch{
            print(error)
        }
    }
    //deleteing note from core data
    func deleteNote(note: Note){
        context.delete(note)
        do{
           try context.save()
        }catch{
            print(error)
        }
    }
    // editing given notes boolean value(isFavourite)
    func editNoteFavourite(note:Note,isFavourite:Bool){
        note.isFavourite = isFavourite
        do {
            try context.save()
        }catch{
            print(error)
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell") as! NotesCell
        cell.noteNameLbl.text = models[indexPath.row].title
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = models[indexPath.row]
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NoteCreateVC") as! NoteCreateVC
        vc.note = note
        vc.noteTitle = note.title!
        vc.noteBodyText = note.noteText!
        vc.delegate = self
        self.navigationController?.present(vc, animated: true)
    }
    //adding delete and edit favourite buttons to cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var favourite = UIContextualAction(style: .normal, title: "Fav") { _, _, completion in
            self.editNoteFavourite(note: self.models[indexPath.row], isFavourite: true)
            completion(true)
            
        }
        if self.models[indexPath.row].isFavourite == true{
            favourite = UIContextualAction(style: .normal, title: "unFav") { _, _, completion in
                
                self.editNoteFavourite(note: self.models[indexPath.row], isFavourite: false)
                if self.segmentIndicator == 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.getDataUsingPredicate()
                    }
                }
                completion(true)
        }
    }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            self.deleteNote(note: self.models[indexPath.row])
            completion(true)
            if self.segmentIndicator == 0 {
                DispatchQueue.main.async {
                    self.getNotes()
                    self.tableView.reloadData()
                }
            }else {
                DispatchQueue.main.async {
                    self.getDataUsingPredicate()
                    self.tableView.reloadData()
                }
            }
        }
        let swipeConf = UISwipeActionsConfiguration (actions: [delete,favourite])
            return swipeConf
    }
}

extension ViewController: NoteCreateVCDelegate{
    func saveNote() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
