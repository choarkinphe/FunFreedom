//
//  FunError.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/25.
//

import Foundation

struct FunError: LocalizedError {
    init(desc: String?) {
        description = desc
    }
    private var description: String?
    var errorDescription: String? {
        return description
    }
}
