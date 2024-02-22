//
//  Transaction+CoreDataProperties.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 13.11.2022.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var currencyPurchased: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var quantityPurchased: Int32
    @NSManaged public var yourCuttency: String?

    
}

extension Transaction : Identifiable {

}
