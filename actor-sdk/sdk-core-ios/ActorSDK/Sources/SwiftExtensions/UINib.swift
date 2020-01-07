//
//  UINib.swift
//  AloSDK
//
//  Created by Alcyone on 14.02.2018.
//

import UIKit

extension UINib {
    
    func instantiate() -> Any? {
        return self.instantiate(withOwner: nil, options: nil).first
    }
    
}
