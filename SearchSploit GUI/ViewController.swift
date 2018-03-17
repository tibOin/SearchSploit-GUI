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
    @IBOutlet weak var urlBox: NSButton!
    @IBOutlet weak var resultsTableView: NSTableView!
    @IBOutlet weak var browserButton: NSButton!
    @IBOutlet weak var openButton: NSButton!
    @IBOutlet weak var exploitNameTBLabel: NSTextField!
    //MARK: Properties
    var exploitsFound: Array<SearchSploit.Exploit>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        excludeField.tokenizingCharacterSet.update(with: " ")
        
        resultsTableView.dataSource = self
        resultsTableView.delegate   = self
        resultsTableView.target     = self
        resultsTableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        exploitNameTBLabel.allowsDefaultTighteningForTruncation = true
        
        searchField.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            if let representedObject = representedObject as? SearchSploit.Exploit {
                openButton.isEnabled = true
                browserButton.isEnabled = true
                exploitNameTBLabel.stringValue = representedObject.title
            }
            else {
                openButton.isEnabled = false
                browserButton.isEnabled = false
            }
        }
    }
    
    lazy var detailViewController: DetailViewController = {
        return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DetailViewController"))
            as! DetailViewController
    }()
    
    override func rightMouseDown(with event: NSEvent) {
        guard representedObject != nil else {
            return
        }
        
        let detailsMenu = NSMenuItem(title: "Show details", action: #selector(showDetails), keyEquivalent: "D")
        let openMenu    = NSMenuItem(title: "Open locally", action: #selector(openFileTB(_:)), keyEquivalent: "O")
        let browseMenu  = NSMenuItem(title: "Browse on exploit-db", action: #selector(showBrowserTB(_:)), keyEquivalent: "B")
        
        let menu = NSMenu(title: "Exploit Details")
        menu.insertItem(detailsMenu, at: 0)
        menu.insertItem(openMenu, at: 1)
        menu.insertItem(browseMenu, at: 2)
        NSMenu.popUpContextMenu(menu, with: event, for: self.view)
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
        
        // Token field
        if let tokens = excludeField.objectValue as? Array<String> {
            options.exclude = tokens
        }
        
        return options
    }
    
    @objc func tableViewDoubleClick(_ sender: Any) {
        
        showDetails()
        
        /*
        if urlBox.state == .on {
            NSWorkspace().open(URL(string: exploit.url)!)
        }
        else {
            NSWorkspace().openFile(exploit.path)
        }
        */
    }
    
    
    @objc func showDetails() {
        guard resultsTableView.selectedRow >= 0,
            let exploit = exploitsFound?[resultsTableView.selectedRow]
            else {
                return
        }
        detailViewController.exploit = exploit
        self.presentViewControllerAsSheet(detailViewController)
    }
    
    @IBAction func openFileTB(_ sender: Any) {
        NSWorkspace().openFile(exploitsFound![resultsTableView.selectedRow].path)
    }
    
    @IBAction func showBrowserTB(_ sender: Any) {
        NSWorkspace().open(URL(string: exploitsFound![resultsTableView.selectedRow].url)!)
    }
    
    @IBAction func search(_ sender: Any) {
        
        if searchField.stringValue != "" {
            let searchTerms = searchField.stringValue.components(separatedBy: " ")
            let options = getOptions()
            if let result = SearchSploit().search(searchTerms, options: options) {
                if let exploits = result.exploits {
                    exploitsFound = exploits
                }
            }
        }
        else {
            exploitsFound = nil
        }
        resultsTableView.reloadData()
    }
}

//MARK: - SearchField Delegate
extension ViewController : NSSearchFieldDelegate {
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        exploitsFound = nil
        resultsTableView.reloadData()
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        search(sender)
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
            text = exploit.title
            cellIdentifier = CellIdentifiers.TitleCell
        }
        
        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if resultsTableView.selectedRow >= 0 && resultsTableView.selectedRow < (exploitsFound?.count)! {
            guard let exploit = exploitsFound?[resultsTableView.selectedRow] else {
                return
            }
            representedObject = exploit
        }
        
    }
}
