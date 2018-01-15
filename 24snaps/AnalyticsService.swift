//
//  AnalyticsService.swift
//  24snaps
//
//  Created by Bobby Ren on 1/15/18.
//  Copyright © 2018 RenderApps LLC. All rights reserved.
//

import UIKit
import Firebase

fileprivate var singleton: AnalyticsService?

@objc public class AnalyticsService: NSObject {
    private lazy var __once: () = {
        // firRef is the global firebase ref
        let firRef = Database.database().reference()
    }()

    // MARK: - Singleton
    static var shared: AnalyticsService {
        if singleton == nil {
            singleton = AnalyticsService()
            singleton?.__once
        }
        
        return singleton!
    }

    @objc func trackEventInBackground(_ event: String, block: (()->Void)?) {
        print("Analytics: tracking \(event)")
        Analytics.logEvent(event, parameters: nil)
        block?()
    }


    @objc func trackEventInBackground(_ event: String, dimensions: NSDictionary?, block: (()->Void)?) {
        print("Analytics: tracking \(event) with info \(dimensions as? [String: Any])")
        // native firebase analytics
        Analytics.logEvent(event, parameters: dimensions as? [String : Any])
        block?()
    }
}
