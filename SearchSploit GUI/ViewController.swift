//
//  ViewController.swift
//  SearchSploit GUI
//
//  Created by Anaelle Saint-Jalm on 16/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Cocoa

//MARK: - Main View Controller
class ViewController: NSViewController {

    //MARK: Interface Builder Outlets
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var excludeField: NSTokenField!
    @IBOutlet weak var caseBox: NSButton!
    @IBOutlet weak var exactBox: NSButton!
    @IBOutlet weak var titlesBox: NSButton!
    @IBOutlet weak var urlBox: NSButton!
    @IBOutlet weak var resultsTableView: NSTableView!
    
    //MARK: Properties
    var exploitsFound: Array<SearchSploit.Exploit>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        excludeField.tokenizingCharacterSet.update(with: " ")
        resultsTableView.dataSource = self
        resultsTableView.delegate   = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func getOptions() -> SearchSploit.Options {
        var options = SearchSploit.Options()
        
        // Check boxes
        if caseBox.state   == .on {
            options.caseSensitive = true
        }
        if exactBox.state  == .on {
            options.exactMatch = true
        }
        if titlesBox.state == .on {
            options.onlyTitle = true
        }
        if urlBox.state    == .on {
            options.showURL = true
        }
        
        // Token field
        if let tokens = excludeField.objectValue as? Array<String> {
            options.exclude = tokens
        }
        
        return options
    }
    
    @IBAction func search(_ sender: Any) {
        let searchTerms = searchField.stringValue.components(separatedBy: " ")
        let options = getOptions()
        if let result = SearchSploit().search(searchTerms, options: options) {
            print("Search terms  : \(result.query)")
            print("DB Path       : \(result.db_path)")
            if let exploits = result.exploits {
                exploitsFound = exploits
            }
        }
        resultsTableView.reloadData()
    }
}


//MARK: - Table View Data Source
extension ViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return exploitsFound?.count ?? 0
    }
}

//MARK: - Table View Delegate
extension ViewController : NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let IdCell       = NSUserInterfaceItemIdentifier(rawValue: "EDBID_Cell")
        static let PlatformCell = NSUserInterfaceItemIdentifier(rawValue: "Platform_Cell")
        static let TypeCell     = NSUserInterfaceItemIdentifier(rawValue: "Type_Cell")
        static let TitleCell    = NSUserInterfaceItemIdentifier(rawValue: "Title_Cell")
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "")
        
        // Check if there are exploits to show in datastore
        guard let exploit = exploitsFound?[row] else {
            return nil
        }
        
        // Now get cell identifier and cell text content for selected column and row
        if tableColumn == tableView.tableColumns[0] {       // EDB_ID column
            text = exploit.id ?? ""
            cellIdentifier = CellIdentifiers.IdCell
        }
        else if tableColumn == tableView.tableColumns[1] {  // Platform column
            text = exploit.platform ?? ""
            cellIdentifier = CellIdentifiers.PlatformCell
        }
        else if tableColumn == tableView.tableColumns[2] {  // Type column
            text = exploit.type ?? ""
            cellIdentifier = CellIdentifiers.TypeCell
        }
        else if tableColumn == tableView.tableColumns[3] {  // Title column
            text = exploit.title ?? ""
            cellIdentifier = CellIdentifiers.TitleCell
        }
        
        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
