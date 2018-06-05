import Foundation
import RealmSwift

private struct SerializationKeys {
    static let type = "type"
    static let responses = "responses"
}

class Emergency: Object {
    @objc dynamic var type: String = ""
    let responses = List<Response>()

    convenience init(type: String, responses: [Response]?) {
        self.init()
        self.type = type

        guard let responses = responses else { return }
        self.responses.append(objectsIn: responses)
    }

    func responsesCount() -> String {
        return String(describing: responses.count)
    }

    func responsesCount() -> Int {
        return responses.count
    }

    func getPoints() -> Points {
        var startOfYear = Date().startOfYear()
        var startOfMonth = Date().startOfMonth()

        if let lastReset =  UserDefaults.standard.object(forKey: "last_point_reset") as? Date {
            startOfYear = startOfYear > lastReset ? startOfYear : lastReset
            startOfMonth = startOfMonth > lastReset ? startOfMonth : lastReset
        }

        let allResponsesCount = responses.count
        let yearlyResponses = responses.filter("date >= %@", startOfYear).count
        let monthyResponse = responses.filter("date >=  %@", startOfMonth).count

        return Points(currentYear: yearlyResponses,
                      currentMonth: monthyResponse,
                      previousMonth: 0,
                      all: allResponsesCount)
    }

    func add(response: Response) {
        responses.append(response)
    }

    func remove(responseAtIndex index: Int) {
        if index >= 0, index < responsesCount() {
            responses.remove(at: index)
        }
    }

    func remove(response: Response) {
        if let index = responses.index(of: response) {
            responses.remove(at: index)
        }
    }

    func toCSV() -> String {
        var csvString = ""
        for response in responses {
            csvString += type + "," + response.toCSV()
            if responses.last != responses {
                csvString += "\n"
            }
        }
        return csvString
    }
}

