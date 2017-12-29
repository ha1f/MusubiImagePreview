//
//  Array+Extension.swift
//  MusubiImagePreview
//
//  Created by ST20591 on 2017/12/29.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

extension Array {
    func isValidIndex(_ index: Int) -> Bool {
        return indices ~= index
    }
    
    func get(_ index: Int) -> Element? {
        guard isValidIndex(index) else {
            return nil
        }
        return self[index]
    }
}
