//
//  FunObserver.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/4/28.
//

import Foundation

public extension FunFreedom {
    class Observer: NSObject {
        lazy var observations: [NSKeyValueObservation] = {
            let observations = [NSKeyValueObservation]()
            
            return observations
        }()
        var handler: ((_ object: Any, _ oldValue: Any, _ newValue: Any)->Void)?
        
//        init(<#parameters#>) {
//            <#statements#>
//        }

        func a() {
//            observations.append(obse)
        }
    }
}


