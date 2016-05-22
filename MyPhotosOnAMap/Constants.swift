//
//  Constants.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 5/7/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class Constants {
    
    public static let MinimumPointsForCluster : Int = 10;
    public static let ClusterRadius : Double = 32.0;
    public static let MapViewFraction : Double = 0.75;
    public static let SizeAdjusterWidth : Double = 10.0;
    
    public static let DateFilterStartDefault : NSDate = Constants.dateWithComponents(1, day: 1, year: 1999);
    public static let DateFilterFinishDefault : NSDate = Constants.dateWithComponents(12, day: 31, year: 2199);
    
    public static func dateWithComponents(month: Int, day: Int, year: Int) -> NSDate {
        
        let calendar : NSCalendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)!;
        let components : NSDateComponents = NSDateComponents.init();
        components.month = month;
        components.day = day;
        components.year = year;
        return calendar.dateFromComponents(components)!;
    }
    
    public static func MessageBox(message : String) {
        
        let alert = NSAlert.init();
        alert.messageText = message;
        alert.runModal();
    }
}

public extension NSDate {
    
    public func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    public func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
}
