//
//  TIoTBaseModel.swift
//  LinkApp
//
//

import Foundation
//@_exported
import YYModel

@objc class TIoTBaseModel: NSObject, NSCoding, YYModel {

    func encode(with aCoder: NSCoder) {
        self.yy_modelEncode(with: aCoder)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.yy_modelInit(with: aDecoder)
    }

    override var description: String {
        return yy_modelDescription()
    }
}
