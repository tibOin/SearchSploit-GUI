//
//  DetailViewController.swift
//  SearchSploit GUI
//
//  Created by Anaelle Saint-Jalm on 17/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController {

    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var idField: NSTextField!
    @IBOutlet weak var platformField: NSTextField!
    @IBOutlet weak var typeField: NSTextField!
    @IBOutlet weak var authorField: NSTextField!
    @IBOutlet weak var dateField: NSTextField!
    //@IBOutlet weak var pathControl: NSPathControl!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var labelTB: NSTextField!
    @IBOutlet weak var openButtonTB: NSButton!
    @IBOutlet weak var browserButtonTB: NSButton!
    
    var exploit: SearchSploit.Exploit?
    
    override func viewWillAppear() {
        prepareView()
    }
    
    override func viewWillDisappear() {
        openButtonTB.isEnabled = false
        browserButtonTB.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func prepareView() {
        guard exploit != nil else {
            self.dismiss(self)
            return
        }
        
        titleField.stringValue    = exploit?.title    ?? ""
        idField.stringValue       = exploit?.id       ?? ""
        platformField.stringValue = exploit?.platform ?? ""
        typeField.stringValue     = exploit?.type     ?? ""
        authorField.stringValue   = exploit?.author   ?? ""
        dateField.stringValue     = exploit?.date     ?? ""
      //pathControl.stringValue   = exploit?.path     ?? ""
        pathField.stringValue     = exploit?.path     ?? ""
        urlField.stringValue      = exploit?.url      ?? ""
        labelTB.stringValue       = exploit?.title    ?? "Error"
        openButtonTB.isEnabled    = true
        browserButtonTB.isEnabled = true
    }
    
    @IBAction func openFile(_ sender: Any) {
        guard exploit != nil else {
            return
        }
        NSWorkspace().openFile((exploit?.path)!)
    }
    
    @IBAction func showBrowser(_ sender: Any) {
        guard exploit != nil else {
            return
        }
        NSWorkspace().open(URL(string: (exploit?.url)!)!)
    }
}
