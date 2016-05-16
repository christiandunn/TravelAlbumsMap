//
//  WindowController.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class WindowController : NSWindowController {
    
    var VC : ViewController?;
    
    @IBOutlet weak var BackButtonImageView: CDImageView!
    @IBOutlet weak var ForwardButtonImageView: CDImageView!
    @IBOutlet weak var LoadFolderImageView: CDImageView!
    @IBOutlet weak var LoadLibraryImageView: CDImageView!
    
    @IBOutlet weak var ZoomSlider: NSToolbarItem!
    @IBOutlet weak var Zoom: NSSlider!
    
    override public func windowDidLoad() {
        
        VC = self.window!.contentViewController as! ViewController?;
        Zoom.continuous = true;
        
        BackButtonImageView.target = self;
        BackButtonImageView.clickAction = #selector(backButtonPressed);
        
        ForwardButtonImageView.target = self;
        ForwardButtonImageView.clickAction = #selector(forwardButtonPressed);
        
        LoadFolderImageView.target = self;
        LoadFolderImageView.clickAction = #selector(openFolder);
        
        LoadLibraryImageView.target = self;
        LoadLibraryImageView.clickAction = #selector(openLibrary);
    }
    
    func backButtonPressed() {
        VC?.backButtonPressed();
    }
    
    func forwardButtonPressed() {
        VC?.forwardButtonPressed();
    }
    
    @IBAction func sliderDidAct(sender: AnyObject) {
        VC?.setImageBrowserZoom(Float(Zoom.doubleValue/100.0));
    }
    
    func openFolder(sender: AnyObject) {
        let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: VC!);
        itemLoader.loadItemsFromDirectory();
    }
    
    func openLibrary(sender: AnyObject) {
        VC?.loadMapWithLibrary();
    }
}