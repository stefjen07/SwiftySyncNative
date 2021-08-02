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

struct Field {
    
}

struct Document {
    var name: String
    var collectionName: String
    var fields: CFieldArray
}

fileprivate func makePath(items: [String]) -> String {
    var encoded = "["
    var notFirst = false
    for pathItem in items {
        if(notFirst) {
            encoded += ","
        } else {
            notFirst = true
        }
        encoded += "\"\(pathItem)\""
    }
    return encoded
}

fileprivate func getCField(field: Field) -> UnsafeMutablePointer<CField> {
    return CField_empty();
}

struct SwiftyNativeClient {
    var id: Int
    
    var isAuthorized: Bool {
        return authorized()
    }
    
    func authorizeUser(provider: AuthProvider, credentials: AuthCredentials) {
        authorize(UInt32(provider.rawValue), credentials.getContent())
    }
    
    func run() {
        run_client()
    }
    
    func callFunction(name: String, bytes: String) -> String {
        guard let cStr = call_function(name, bytes) else { return "" }
        return String(cString: cStr)
    }
    
    func getDocument(collectionName: String, documentName: String) -> Document {
        let arr = get_document(collectionName, documentName)
        let result = Document(name: documentName, collectionName: collectionName, fields: arr)
        return result
    }
    
    func setDocument(_ document: Document) {
        set_document(document.collectionName, document.name, document.fields)
    }
    
    func getField(collectionName: String, documentName: String, path: [String]) -> Field {
        let field = get_field(collectionName, documentName, makePath(items: path))
        let result = Field()
        return result
    }
    
    func setField(collectionName: String, documentName: String, path: [String], field: Field) {
        set_field(collectionName, documentName, makePath(items: path), getCField(field: field))
    }
    
    init(uri: String) {
        self.id = 0
        create_client(uri)
    }
}

let client = SwiftyNativeClient(uri: "ws://localhost:8888")
client.run()

client.authorizeUser(provider: .debug, credentials: .init())
while(!client.isAuthorized) {
    sleep(5)
    client.authorizeUser(provider: .debug, credentials: .init())
}

let field = CField_new(cft_string, "age")
var ageName = "age".utf8CString
ageName.withUnsafeMutableBytes { ptr in
    field?.pointee.name = ptr.baseAddress!.bindMemory(to: CChar.self, capacity: ptr.count)
}
var age = "17_years".utf8CString
age.withUnsafeMutableBytes { ptr in
    field?.pointee.str_value = ptr.baseAddress!.bindMemory(to: CChar.self, capacity: ptr.count)
}
let doc = Document(name: "stefjen07", collectionName: "users", fields: CFieldArray(ptr: field, size: 1))

client.setDocument(doc)
let receivedDoc = client.getDocument(collectionName: "users", documentName: "stefjen07")
let ageField = get_array_child(receivedDoc.fields, "age")

if(ageField == nil) {
    print("Age field was not provided")
} else {
    print("stefjen07's age is \(String(cString: ageField!.pointee.str_value))")
}

print("Function returned \(client.callFunction(name: "nothing", bytes: "nothing"))")
