//
//  FunError.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/25.
//

import Foundation

struct FunError: LocalizedError {
    // desc会直接传入给localizedDescription
    init(desc: String?) {
        description = desc
    }
    // 内部变量暂存错误信息
    private var description: String?
    
    var errorDescription: String? {
        return description
    }
}
