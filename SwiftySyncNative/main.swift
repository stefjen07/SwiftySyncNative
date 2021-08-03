import Foundation

let client = SwiftyNativeClient(uri: "ws://localhost:8888")
client.run()

while(!client.isAuthorized) {
    client.authorizeUser(provider: .debug, credentials: .init())
    sleep(5)
}

let field = Field(name: "age", value: "17_years")
let doc = Document(name: "stefjen07", collectionName: "users", fields: Field(name: "", children: [field]))
client.setDocument(doc)

let receivedDoc = client.getDocument(collectionName: "users", documentName: "stefjen07")
let ageField = receivedDoc.fields["age"]

print("stefjen07's age is \(ageField.value as! String)")

print("Function returned \(client.callFunction(name: "nothing", bytes: "nothing"))")
