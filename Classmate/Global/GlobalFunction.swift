//
//  GlobalFunction.swift
//  Classmate
//
//  Created by Administrator on 7/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AZDialogView

open class GlobalFunction {
    
    open class var sharedManager: GlobalFunction {
        struct Static {
            static let instance: GlobalFunction = GlobalFunction()
        }
        return Static.instance
    }
    
    open func showProgressView(_ message: String) {
        let activityData = ActivityData.init(size: CGSize.init(width: 50, height: 50), message: message, messageFont: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold), type: NVActivityIndicatorType.ballBeat, color: UIColor.white, padding: 0, displayTimeThreshold: 5, minimumDisplayTime: 5, backgroundColor: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5), textColor: UIColor.white)
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    open func hideProgressView() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    open func showAlertMessageWithOptions(_ title: String, _ message: String, _ cancelButtonText: String, _ okButtonText: String, completion : @escaping (_ success : Bool) -> Void) {
        let dialog = AZDialogViewController.init(title: title, message: message)
        let yesAction = AZDialogAction.init(title: okButtonText) { (dialog) -> (Void) in
            dialog.dismiss()
            completion(true)
        }
        dialog.addAction(yesAction)

        dialog.cancelEnabled = true
        dialog.cancelButtonStyle = {(button, height) in
            button.tintColor = UIColor.darkGray
            button.setTitle(cancelButtonText, for: [])
            return true
        }
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(dialog, animated: false, completion: nil)
        }
    }
    
    open func showAlertMessage(_ title: String?, _ message: String?) {
        let dialog = AZDialogViewController.init(title: title, message: message)
        let okAction = AZDialogAction.init(title: "OK") { (dialog) -> (Void) in
            dialog.dismiss()
        }
        dialog.addAction(okAction)
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(dialog, animated: false, completion: nil)
        }
    }
    
    open func getLocalTimeStampFromUTC(_ utc: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: utc) else { return "" }
        
        if GlobalVariable.sharedManager.is24Format {
            dateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy - H:mm"
        }
        
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
        
    }
}
