//
//  AnalyticsService.swift
//  24snaps
//
//  Created by Bobby Ren on 1/15/18.
//  Copyright © 2018 RenderApps LLC. All rights reserved.
//

import UIKit

@objc public class AnalyticsService: NSObject {
    @objc func trackEventInBackground(_ event: String, block: (()->Void)?) {
        print("Tracking \(event)")
    }

    @objc func trackEventInBackground(_ event: String, dimensions: NSDictionary?, block: (()->Void)?) {
        print("Tracking \(event)")
    }
}
