import Foundation

private struct SerializationKeys {
    static let type = "type"
    static let responses = "responses"
}

class Call: NSObject, NSCoding {
    var type: String
    var responses: [Response]?

    init(type: String, responses: [Response]?) {
        self.type = type
        self.responses = responses
    }

    func responsesCount() -> Int {
        return responses?.count ?? 0
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: SerializationKeys.type)
        aCoder.encode(responses, forKey: SerializationKeys.responses)
    }

    required init?(coder aDecoder: NSCoder) {
        type = aDecoder.decodeObject(forKey: SerializationKeys.type) as? String ?? ""
        responses = aDecoder.decodeObject(forKey: SerializationKeys.responses) as? [Response]
    }
}

