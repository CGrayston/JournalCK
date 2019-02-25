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
    
    private init() {}
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
        
        // Save
        save(entry: entry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Update
    func updateEntry(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> Void){
        
        //Update the entry locally
        entry.title = title
        entry.body = body
        
        //Update the entry
        privateDB.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error{
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let record = record else {completion(false) ; return}
            
            record[Constants.titleKey] = title
            record[Constants.bodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, reordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operation)
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
