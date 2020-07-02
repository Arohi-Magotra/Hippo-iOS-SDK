//
//  PaymentPlan.swift
//  HippoAgent
//
//  Created by Vishal on 05/12/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class PaymentPlan {
    let planId: Int
    let planName: String
    
    var options: [PaymentItem] = []
    var type: PaymentPlanType = .agentPlan
    var updatedAt: Date?

    var ownerName: String?
    var ownerID: Int?
    var displayOwner: String?
    
    var currency: PaymentCurrency?
    
    var canEdit: Bool = false
    
    init?(json: [String: Any]) {
        guard let id = Int.parse(values: json, key: "plan_id"), let planName = String.parse(values: json, key: "plan_name") else {
            return nil
        }
        self.planId = id
        self.planName = planName.capitalized
        
        if let planType = Int.parse(values: json, key: "type"), let type = PaymentPlanType(rawValue: planType) {
            self.type = type
        }
        
        
        if let plans = json["plans"] as? [[String: Any]] {
            self.options = PaymentItem.parses(options: plans)
        }
        currency = options.first?.currency
        if let updated_at = String.parse(values: json, key: "updated_at"), let date = updated_at.toDate {
            self.updatedAt = date
        }
        ownerName = String.parse(values: json, key: "full_name") ?? String.parse(values: json, key: "email")
        
        ownerID = Int.parse(values: json, key: "user_id")
        
//        displayOwner = (ownerID ?? -100) == (PersonInfo.current?.userID ?? -10) ? "Self" : ownerName
        displayOwner = (ownerID ?? -100) == (currentUserId() ?? -10) ? "Self" : ownerName
        displayOwner = displayOwner?.capitalized
        
//        canEdit = (ownerID ?? -100) == (PersonInfo.current?.userID ?? -10)
        canEdit = (ownerID ?? -100) == (currentUserId() ?? -10)
        
    }
    
    static func parse(plans: [[String: Any]]) -> [PaymentPlan] {
        var list: [PaymentPlan] = []
        
        for plan in plans {
            guard let p = PaymentPlan(json: plan) else {
                continue
            }
            list.append(p)
        }
        return list
    }
    
}
