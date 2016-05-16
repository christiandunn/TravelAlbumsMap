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
            Stack.push(element);
            return;
        }
        if !regionsAreSimilar(top!, region2: element) {
            Stack.push(element);
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
    
    private func regionsAreSimilar(region1: MKCoordinateRegion, region2: MKCoordinateRegion) -> Bool {
        
        let span1 = region1.span;
        
        let center1 = region1.center;
        let center2 = region2.center;
        
        let movedLongitudinally = abs(Double(center2.longitude - center1.longitude)) > span1.longitudeDelta * 0.25;
        if movedLongitudinally {
            return false;
        }
        
        let movedLatitudinally = abs(Double(center2.latitude - center1.latitude)) > span1.latitudeDelta * 0.25;
        if movedLatitudinally {
            return false;
        }
        
        let latitudeDeltaCompare = region2.span.latitudeDelta / region1.span.latitudeDelta;
        let longitudeDeltaCompare = region2.span.longitudeDelta / region1.span.longitudeDelta;
        if latitudeDeltaCompare < 0.75 || latitudeDeltaCompare > 1.25 {
            return false;
        }
        if longitudeDeltaCompare < 0.75 || latitudeDeltaCompare > 1.25 {
            return false;
        }
        
        return true;
    }
}