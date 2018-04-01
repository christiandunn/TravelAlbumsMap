//
//  SaveDialogService.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class SaveDialogService {
    
    var VC : ViewController;
    
    enum SaveCsvInstructions {
        case None
        case SaveAll
        case SaveVisible
    };
    
    var CsvInstructions : SaveCsvInstructions;
    
    init(withViewController viewController : ViewController) {
        
        VC = viewController;
        CsvInstructions = SaveCsvInstructions.None;
    }
    
    public func saveCsvAll() {
        
        CsvInstructions = SaveCsvInstructions.SaveAll;
        getPath();
    }
    
    public func saveCsvVisible() {
        
        CsvInstructions = SaveCsvInstructions.SaveVisible;
        getPath();
    }
    
    private func getPath() {
        
        let window = NSApplication.shared().mainWindow;
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = false
        savePanel.beginSheetModal(for: window!, completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let url = savePanel.url;
                self.VC.exportToCsv(path: url! as NSURL, instructions: self.CsvInstructions);
            }
        });
    }
}
