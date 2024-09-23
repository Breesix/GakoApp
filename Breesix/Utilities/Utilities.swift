//
//  Utilities.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        // Safely unwrap the controller
        guard let controller = controller ?? UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            return nil
        }
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}

