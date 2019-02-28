//
//  FuguChannelPersistancyManager.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 14/12/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation


class FuguChannelPersistancyManager {
   static let shared = FuguChannelPersistancyManager()
   
   private var channels = [FuguChannel]()
   let maxChannelCount = 5
   
   
   private init() {
   }
   
   func getChannelBy(id: Int) -> FuguChannel {
      
      if let channel = findChannelWithID(id: id) {
         return channel
      }
      
      let newChannel = createNewChannelWith(id: id)
      return newChannel
   }
   
   private func findChannelWithID(id: Int) -> FuguChannel? {
      for channel in channels {
         if channel.id == id {
            return channel
         }
      }
      
      return nil
   }
   
   private func createNewChannelWith(id: Int) -> FuguChannel {
      if channels.count >= maxChannelCount {
         removeLeastPriorityChannel()
      }
      
      let newChannel = FuguChannel(id: id)
      channels.append(newChannel)
      
      return newChannel
   }
   
   private func removeLeastPriorityChannel() {
      guard channels.count > 0 else {
         return
      }
      
      channels.remove(at: 0)
   }
   
   func clearChannels() {
      channels.removeAll()
   }
   
}
