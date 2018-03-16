//
//  SearchSploit.swift
//  SearchSploit GUI
//
//  Created by Anaelle Saint-Jalm on 16/03/2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Cocoa

class SearchSploit: NSObject {
    
    // MARK: Data Structures
    public struct Options {
        var caseSensitive: Bool?
        var exactMatch: Bool?
        var onlyTitle: Bool?
        var showURL: Bool?
        var exclude: Array<String>? {
            get {
                return self._exStore
            }
            set {
                if let newValue = newValue {
                    self._exStore = Set(newValue).sorted()
                }
            }
        }
        private var _exStore : Array<String>?
    }
    
    struct Exploit {
        let title    : String!
        let path     : String!
        let url      : String!
        var author   : String?
        var id       : String?
        var type     : String?
        var date     : String?
        var platform : String?
        
        init(title: String, path: String, author: String? = nil, id: String? = nil, type: String? = nil, date: String? = nil, platform: String? = nil) {
            self.title    = title
            self.path     = path
            self.author   = author
            self.id       = id
            self.type     = type
            self.date     = date
            self.platform = platform
            
            let filename = path.components(separatedBy: "/").last!
            let db_id    = filename.components(separatedBy: ".").first!
            self.url     =  "https://www.exploit-db.com/exploits/\(db_id)/"
        }
    }
    
    struct Result {
        let query  : String
        let db_path : String
        let exploits: Array<Exploit>?
        
        init(query: String, db_path: String, exploits: Array<Exploit>? = nil) {
            self.query = query
            self.db_path = db_path
            if let exploits = exploits {
                if exploits.count == 0 {
                    self.exploits = nil
                }
                else {
                    self.exploits = exploits
                }
            }
            else {
                self.exploits = exploits
            }
        }
    }
    
    // MARK: Main
    public func search(_ terms: Array<String>, options: Options? = nil) -> Result? {
        let binaryPath = "/usr/local/bin/searchsploit"
        var args = [binaryPath, "-j"] // We systematically add the -j option as we parse JSON data
        
        if let options = options {
            args.append(contentsOf: argsFromOptions(options))
        }
        
        args.append(contentsOf: terms)
        
        if let out = cmdline(args) {
            do {
                let json = try JSONSerialization.jsonObject(with: out.data(using: .utf8)!) as? Dictionary<String, Any>
                let query = json!["SEARCH"] as! String
                let db_path = json!["DB_PATH"] as! String
                var exploits = [Exploit]()
                if let results = json!["RESULTS"] as? Array<Dictionary<String, String>> {
                    for result in results {
                        exploits.append(dict2exploit(result: result))
                    }
                }
                return Result(query: query, db_path: db_path, exploits: exploits)
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func dict2exploit(result: Dictionary<String, String>) -> Exploit {
        let title = result["Exploit Title"]!
        let path  = result["Path"]!
        var exploit = Exploit(title: title, path: path)
        
        if let id = result["EDB-ID"] {
            exploit.id = id
        }
        if let author = result["Author"] {
            exploit.author = author
        }
        if let platform = result["Platform"] {
            exploit.platform = platform
        }
        if let type = result["Type"] {
            exploit.type = type
        }
        if let date = result["Date"] {
            exploit.date = date
        }
        return exploit
    }
    
    // MARK: Internal functions
    private func argsFromOptions(_ options: Options) -> Array<String> {
        var args = [String]()
        
        if let _ = options.caseSensitive {
            args.append("-c")
        }
        
        if let _ = options.exactMatch {
            args.append("-e")
        }
        
        if let _ = options.onlyTitle {
            args.append("-t")
        }
        
        if let _ = options.showURL {
            args.append("-w")
        }
        
        if let terms = options.exclude {
            var arg = "--exclude=\""
            for term in terms {
                if term == terms.last {
                    arg += "\(term)\""
                }
                else {
                    arg += "\(term)|"
                }
            }
            args.append(arg)
        }
        return args
    }
    
    private func cmdline(_ commands: Array<String>) -> String? {
        // Create the output stream and the subprocess
        let pipe = Pipe()
        let task = Process()
        
        // Set subprocesse's parameters and commands then launch it.
        task.launchPath = commands[0]
        task.arguments = Array<String>(commands.suffix(commands.count - 1))
        task.standardOutput = pipe
        task.launch()
        
        // Get subprocesse's output
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        // Return output as String.
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
