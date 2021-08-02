//
//  main.swift
//  SwiftySyncNative
//
//  Created by Евгений on 01.08.2021.
//

import Foundation

enum AuthProvider: Int {
    case facebook = 0
    case google
    case debug
}

class AuthCredentials {
    func getContent() -> String {
        return ""
    }
}

class FacebookCredentials: AuthCredentials {
    
}

class GoogleCredentials: AuthCredentials {
    
}

class DebugCredentials: AuthCredentials {
    
}

struct SwiftyNativeClient {
    var isAuthorized: Bool {
        return authorized()
    }
    
    func authorizeUser(provider: AuthProvider, credentials: AuthCredentials) {
        authorize(UInt32(provider.rawValue), credentials.getContent())
    }
    
    func run() {
        runClient()
    }
    
    func callFunction(name: String, bytes: String) -> String {
        guard let cStr = call_function(name, bytes) else { return "" }
        return String(cString: cStr)
    }
    
    init(uri: String) {
        createClient(uri)
    }
}

let client = SwiftyNativeClient(uri: "ws://localhost:8888")
client.run()

client.authorizeUser(provider: .debug, credentials: .init())
while(!client.isAuthorized) {
    sleep(5)
    client.authorizeUser(provider: .debug, credentials: .init())
}

print("Function returned \(client.callFunction(name: "nothing", bytes: "nothing"))")
