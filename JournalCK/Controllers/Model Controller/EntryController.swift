//
//  EntryController.swift
//  JournalCK
//
//  Created by Chris Grayston on 2/25/19.
//  Copyright © 2019 Chris Grayston. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    // MARK: - Shared Instance
    static let entryContoller = EntryController()
    
    // MARK: - Source of Truth
    var entries: [Entry] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // Save
    func save(entry: Entry, completion: @escaping (Bool) -> ()) {
        let entryRecord = CKRecord(entry: entry)
        CKContainer.default().privateCloudDatabase.save(entryRecord) { (record, error) in
            if let error = error {
                print("There was an error in \(error): \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let record = record, let entry = Entry(ckRecord: record) else {
                completion(false)
                return
            }
            self.entries.append(entry)
            completion(true)
        }
    }
    
    // Create
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> ()) {
        // Create and append entry
        let entry = Entry(title: title, body: body)
        self.entries.append(entry)
        
        // Save
        save(entry: entry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> ()) {
        // This will fetch all the entries in your private database.
        
        // Create a CKQuery
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            let entries = records.compactMap { Entry(ckRecord: $0)}
            self.entries = entries
            completion(true)
        }
        
    }
    
    
    
    
    
}
