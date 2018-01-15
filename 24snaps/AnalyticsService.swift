//
//  AnalyticsService.swift
//  24snaps
//
//  Created by Bobby Ren on 1/15/18.
//  Copyright © 2018 RenderApps LLC. All rights reserved.
//

import UIKit

class AnalyticsService: NSObject {
    func trackEventInBackground(_ event: String, block: (()->Void)) {
        print("Tracking \(event)")
    }
}
