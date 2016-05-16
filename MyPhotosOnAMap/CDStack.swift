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
        let item = peek();
        removeStackHead();
        return item;
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
    
    func removeAll() {        
        while let node = StackHead {
            StackHead = node.Before;
        }
    }
    
    func peek() -> T? {
        if let firstNode = StackHead {
            return firstNode.Element;
        } else {
            return nil;
        }
    }
    
    func removeStackHead() {
        StackHead = StackHead?.Before;
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
