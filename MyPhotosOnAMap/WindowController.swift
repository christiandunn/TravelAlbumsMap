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
    @IBOutlet weak var DateFilterImageView: CDImageView!
    @IBOutlet weak var ConnectPointsImageView: CDImageView!
    @IBOutlet weak var SelectPointsImageView: CDImageView!
    
    @IBOutlet weak var ZoomSlider: NSToolbarItem!
    @IBOutlet weak var Zoom: NSSlider!
    
    override public func windowDidLoad() {
        
        VC = ViewController.getMainViewController();
        Zoom.isContinuous = true;
        
        BackButtonImageView.target = self;
        BackButtonImageView.action = #selector(backButtonPressed);
        
        ForwardButtonImageView.target = self;
        ForwardButtonImageView.action = #selector(forwardButtonPressed);
        
        LoadFolderImageView.target = self;
        LoadFolderImageView.action = #selector(openFolder);
        
        LoadLibraryImageView.target = self;
        LoadLibraryImageView.action = #selector(openLibrary);
        
        ConnectPointsImageView.target = self;
        ConnectPointsImageView.action = #selector(connectPoints);
        
        SelectPointsImageView.target = self;
        SelectPointsImageView.action = #selector(selectPoints);
    }
    
    func backButtonPressed() {
        VC?.backButtonPressed();
    }
    
    func forwardButtonPressed() {
        VC?.forwardButtonPressed();
    }
    
    @IBAction func sliderDidAct(sender: AnyObject) {
        VC?.setImageBrowserZoom(zoom: Float(Zoom.doubleValue/100.0));
    }
    
    func openFolder(sender: AnyObject) {
        let itemLoader : ItemsInDirectoryLoader = ItemsInDirectoryLoader.init(withViewController: VC!);
        itemLoader.loadItemsFromDirectory();
    }
    
    func openLibrary(sender: AnyObject) {
        VC?.loadMapWithLibrary();
    }
    
    func dateFilter(sender: AnyObject) {
        
    }
    
    func connectPoints(sender: AnyObject) {
        
        print("ConnectPoints");
    }
    
    func selectPoints(sender: AnyObject) {
        
        VC?.selectPointsInit();
    }
}
