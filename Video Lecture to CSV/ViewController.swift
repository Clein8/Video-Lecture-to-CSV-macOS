//
//  ViewController.swift
//  Video Lecture to CSV
//
//  Created by 이병진 on 2018. 12. 21..
//  Copyright © 2018년 Clein8. All rights reserved.
//

import Cocoa
import Kanna

class Lecture: NSObject {
    @objc dynamic var idx: String
    @objc dynamic var date: String
    @objc dynamic var title: String
    @objc dynamic var time: String
    
    init(idx: String, date: String, title: String, time: String) {
        self.idx = idx
        self.date = date
        self.title = title
        self.time = time
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var getButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    @objc dynamic var lectures = [Lecture]()
    var l_title = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func getAction(sender: AnyObject) {
        var html = ""
        guard let url = URL(string: urlField.stringValue) else {
            let alert = NSAlert()
            alert.messageText = "주소 없음"
            alert.informativeText = "강좌 주소를 입력해 주세요."
            alert.runModal()
            return
        }
        lectures = [Lecture]()
        if urlField.stringValue.contains("my.conects.com") {
            do {
                let stream = try String(contentsOf: url, encoding: .utf8)
                let doc = try HTML(html: stream, encoding: .utf8)
                for box in doc.xpath("//div[@class='lecture-config-block']") {
                    l_title = (box.at_xpath("//h5")?.text!.trim())!
                    html = (box.at_xpath("ul")?.innerHTML)!
                }
            } catch { print(error) }
            
            do {
                let ul = try HTML(html: html, encoding: .utf8)
                for li in ul.xpath("//li") {
                    var idex = ""
                    var name = ""
                    var time = ""
                    var date = ""
                    //                var lecture = Lecture(idx: Int, )
                    do {
                        let row = try HTML(html: li.innerHTML!, encoding: .utf8)
                        for idx in row.xpath("//span") {
                            let str = idx.text!.trimmingCharacters(in: ["\n"])
                            idex = str.trim()
                        }
                        for title in row.xpath("//p") {
                            let str0 = title.text!.trimmingCharacters(in: ["\n"])
                            let str1 = str0.components(separatedBy: "_")
                            let str2 = str1[1].components(separatedBy: "p.")
                            let str3 = str2[0].components(separatedBy: "P.")
                            date = str1[0].trim()
                            name = str3[0].trim()
                        }
                        for fort in row.xpath("//div") {
                            let str = fort.text!.trimmingCharacters(in: ["\n"])
                            if str.contains("시간") {
                                let hour = str.components(separatedBy: "시간")[0]
                                let str1 = str.components(separatedBy: "시간")[1].components(separatedBy: "분")
                                time = hour + ":" + String(format: "%02d", Int(str1[0])!) + ":" + String(format: "%02d", Int(str1[1].trimmingCharacters(in: ["초"]))!)
                            } else {
                                let str1 = str.components(separatedBy: "분")
                                time = String(format: "%02d", Int(str1[0])!) + ":" + String(format: "%02d", Int(str1[1].trimmingCharacters(in: ["초"]))!)
                            }
                        }
                        let lecture = Lecture(idx: idex, date: date, title: name, time: time)
                        lectures.append(lecture)
                    } catch { print(error) }
                    //print(lecture)
                }
//                print(l_title)
            } catch { print(error) }
            saveButton.isEnabled = true
        } // 공단기
    }
        
    @IBAction func saveAction(sender: AnyObject) {
        let csvName = l_title+".csv"
        var csvText = "Index,Date,Title,Time\n"
        for task in lectures {
            var newLine = "\(task.idx),\(task.date),"
            if task.title.contains(",") {
                newLine = newLine + "\"\(task.title)\","
            } else {
                newLine = newLine + "\(task.title),"
            }
            newLine = newLine + "\(task.time)\n"
            csvText.append(newLine)
        }
        
        if csvText != "" {
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = ["csv"]
            savePanel.nameFieldStringValue = csvName
            savePanel.begin { (result) -> Void in
                if result == NSApplication.ModalResponse.OK {
                    let fileName = savePanel.url
                    do {
                        try csvText.write(to: fileName!, atomically: true, encoding: .utf8)
                    } catch { print(error) }
                }
            }
        }
    }
    
    @IBAction func gongdangi(sender: AnyObject) {
        openSite(url: "https://gong.conects.com/gong/teacher/lists")
    }
    
    func openSite(url: String) {
        NSWorkspace.shared.open(URL(string: url)!)
    }

}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
