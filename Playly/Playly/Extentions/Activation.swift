//
// Created by Max on 10/4/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Cocoa
import Foundation
import Paddle

extension AppDelegate {
    var needActivation: Bool {
        get {
            !(paddleProduct?.activated ?? false) && (paddleProduct?.trialStartDate == nil || paddleProduct?.trialDaysRemaining == 0)
        }
    }

    var isTrial: Bool {
        get {
            Int(paddleProduct?.trialDaysRemaining ?? 0) > 0
        }
    }

    func initPaddle() {
        let defaultProductConfig = PADProductConfiguration()
        defaultProductConfig.productName = "Payly"
        defaultProductConfig.vendorName = "Max Diachenko"

        paddle = Paddle.sharedInstance(withVendorID: myPaddleVendorID, apiKey: myPaddleAPIKey, productID: myPaddleProductID, configuration: defaultProductConfig, delegate: nil)
        paddle?.canForceExit = true
        paddleProduct = PADProduct(productID: myPaddleProductID, productType: PADProductType.sdkProduct, configuration: defaultProductConfig)
    }

    @objc func showActivationWindow() {
        paddle?.showProductAccessDialog(with: paddleProduct as! PADProduct)
    }

    func checkActivationAsync() {
        paddleProduct?.refresh { (delta: [AnyHashable: Any]?, error: Error?) in
            if self.needActivation {
                self.paddle?.showProductAccessDialog(with: self.paddleProduct as! PADProduct)
                self.blockApp()
            }
        }
    }

    func blockApp() {
        statusItemPrev.action = nil
        statusItemPlay.action = nil
        statusItemNext.action = nil
    }
}
