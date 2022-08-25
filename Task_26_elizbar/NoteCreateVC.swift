//
//  NoteCreateVC.swift
//  Task_26_elizbar
//
//  Created by alta on 8/26/22.
//

import UIKit
protocol NoteCreateVCDelegate{
    func saveNote()
}
class NoteCreateVC: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var noteTitle = ""
    var noteBodyText = ""
    var note = Note()
    var delegate : NoteCreateVCDelegate?
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteBodyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = note.title
        noteBodyTextField.text = note.noteText
    }
    
    @IBAction func noteSaveBtn(_ sender: Any) {
        if let title = titleTextField.text , let noteText = noteBodyTextField.text{
            editNoteBody(note: note, title: title, noteText: noteText)
            self.dismiss(animated: true)
            self.delegate!.saveNote()
        }
        
    }
    func editNoteBody(note: Note,title:String,noteText:String){
        note.title = title
        note.noteText = noteText
        do {
            try context.save()
            
        }catch{
            print(error)
        }
    }

}
