//
//  Speaker.swift
//  RxSwiftPractice
//
//  Created by Yuki Yoshioka on 2018/02/23.
//  Copyright © 2018年 rikusouda. All rights reserved.
//

import Foundation

struct Speaker: Codable {
    var name: String?
    var description: String?
    var avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case description = "Description"
        case avatar = "Avatar"
    }
}
