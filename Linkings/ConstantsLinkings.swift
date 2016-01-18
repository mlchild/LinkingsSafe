//
//  Constants.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

public typealias BlankBlock = () -> ()


struct Constants {
    struct NSNotification {
        static let LocalDataChanged = "localDataChanged"
        static let FetchDataChanged = "fetchDataChanged"
        static let NotificationsRegistered = "notificationsRegistered"
        static let UploadedPost = "uploadedPost"
    }
}

enum Error: ErrorType {
    case NoCurrentUser
    case NoObjectId
    case NoNetworkConnection
    case NoPFQuery
    case NoLocalDatastore
    case UserPermissionsInadequate
    case IndexOutOfRange
    case InvalidURL
    case InvalidActivityType
}