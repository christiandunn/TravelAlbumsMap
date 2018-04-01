//
//  CDMapRegionStack.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class CDMapRegionStack {
    
    var Stack : CDStack<MKCoordinateRegion>;
    
    init() {
        Stack = CDStack();
    }
    
    func push(element: MKCoordinateRegion) {
        
        let top = Stack.peek();
        if top == nil {
            Stack.push(element: element);
            return;
        }
        if !CDMapRegionStack.regionsAreSimilar(region1: top!, region2: element) {
            Stack.push(element: element);
        }
    }
    
    func pop() -> MKCoordinateRegion? {
        
        if Stack.count() > 1 {
            return Stack.pop();
        } else {
            return nil;
        }
    }
    
    func count() -> Int {
        
        return Stack.count();
    }
    
    func removeAll() {
        
        Stack.removeAll();
    }
    
    public static func regionsAreSimilar(region1: MKCoordinateRegion, region2: MKCoordinateRegion) -> Bool {
        
        return CDMapRegionStack._regionsAreSimilar(region1: region1, region2: region2, latDeltaFactor: 0.25, zoomDeltaFactorConstant: 0.25);
    }
    
    public static func regionsAreSimilarIntolerant(region1: MKCoordinateRegion, region2: MKCoordinateRegion) -> Bool {
        
        return CDMapRegionStack._regionsAreSimilar(region1: region1, region2: region2, latDeltaFactor: 0.02, zoomDeltaFactorConstant: 0.02);
    }
    
    private static func _regionsAreSimilar(region1: MKCoordinateRegion, region2: MKCoordinateRegion, latDeltaFactor: Double, zoomDeltaFactorConstant: Double) -> Bool {
        
        let span1 = region1.span;
        
        let center1 = region1.center;
        let center2 = region2.center;
        
        let movedLongitudinally = abs(Double(center2.longitude - center1.longitude)) > span1.longitudeDelta * latDeltaFactor;
        if movedLongitudinally {
            return false;
        }
        
        let movedLatitudinally = abs(Double(center2.latitude - center1.latitude)) > span1.latitudeDelta * latDeltaFactor;
        if movedLatitudinally {
            return false;
        }
        
        let latitudeDeltaCompare = region2.span.latitudeDelta / region1.span.latitudeDelta;
        let longitudeDeltaCompare = region2.span.longitudeDelta / region1.span.longitudeDelta;
        if latitudeDeltaCompare < (1 - zoomDeltaFactorConstant) || latitudeDeltaCompare > (1 + zoomDeltaFactorConstant) {
            return false;
        }
        if longitudeDeltaCompare < (1 - zoomDeltaFactorConstant) || latitudeDeltaCompare > (1 + zoomDeltaFactorConstant) {
            return false;
        }
        
        return true;
    }
}
