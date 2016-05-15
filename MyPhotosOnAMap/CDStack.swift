//
//  CDStack.swift
//  The Photo Map
//
//  Created by Christian Dunn on 5/15/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class CDStack<T> {
    
    var StackHead : CDStackNode<T>?;
    
    init() {
        StackHead = nil;
    }
    
    func push(element: T) {
        let newNode = CDStackNode.init(element: element, before: StackHead);
        StackHead = newNode;
    }
    
    func pop() -> T? {
        if let firstNode = StackHead {
            let element = firstNode.Element;
            StackHead = firstNode.Before;
            return element;
        } else {
            return nil;
        }
    }
    
    func count() -> Int {
        var numItems = 0;
        var currentNode = StackHead;
        while let node = currentNode {
            numItems = numItems + 1;
            currentNode = node.Before;
        }
        return numItems;
    }
}

class CDStackNode<T> {
    
    var Element : T;
    var Before: CDStackNode<T>?;
    
    init(element: T, before: CDStackNode<T>?) {
        Element = element;
        Before = before;
    }
}
