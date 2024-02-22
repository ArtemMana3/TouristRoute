//
//  Transaction+CoreDataProperties.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 14.11.2022.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var currencyPurchased: String?
    @NSManaged public var id: UUID?
    @NSManaged public var quantity: Int32
    @NSManaged public var quantityPurchased: Int32
    @NSManaged public var yourCurrency: String?

}

extension Transaction : Identifiable {

}
