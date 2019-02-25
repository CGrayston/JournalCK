//
//  EntryListTableViewController.swift
//  JournalCK
//
//  Created by Chris Grayston on 2/25/19.
//  Copyright © 2019 Chris Grayston. All rights reserved.
//

import UIKit

class EntryListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        EntryController.entryContoller.fetchEntries { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EntryController.entryContoller.entries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        let entry = EntryController.entryContoller.entries[indexPath.row]
        cell.textLabel?.text = entry.title
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as? EntryDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let entry = EntryController.entryContoller.entries[indexPath.row]
            destinationVC?.entry = entry
        }
    }
    

}
