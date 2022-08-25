//
//  Note+CoreDataProperties.swift
//  Task_26_elizbar
//
//  Created by alta on 8/26/22.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var noteText: String?
    @NSManaged public var isFavourite: Bool

}

extension Note : Identifiable {

}
