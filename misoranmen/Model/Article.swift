//
//  Qiita.swift
//  misoranmen
//
//  Created by 宮本光直 on 2021/06/28.
//

import Foundation

struct Article: Codable, Identifiable, Equatable {
    let id: String
    let url: String
    let title: String
    let user: User
}

struct User: Codable, Equatable {
    let name: String
    let profile_image_url: String
}
