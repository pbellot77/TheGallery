//
//  Art+CoreDataProperties.swift
//  The Gallery
//
//  Created by Patrick Bellot on 8/16/17.
//  Copyright © 2017 Polestar Interactive LLC. All rights reserved.
//

import Foundation
import CoreData


extension Art {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Art> {
        return NSFetchRequest<Art>(entityName: "Art")
    }

    @NSManaged public var title: String?
    @NSManaged public var imageName: String?
    @NSManaged public var purchased: Bool
    @NSManaged public var productIdentifier: String?

}
