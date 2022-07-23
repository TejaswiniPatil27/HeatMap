//
//  SymbolDetails.swift
//  HeatMap
//
//  Created by Tejaswini Kotagi on 22/07/22.
//

import Foundation

struct SymbolDetails{
    var name: String?
    var pricePercentage: String?
    var category: String?
    var index: Int
    
    init(name: String? = nil, pricePercentage: String? = nil, category: String? = nil, index: Int) {
        self.name = name
        self.pricePercentage = pricePercentage
        self.category = category
        self.index = index
    }
}
