import AWSLambdaSwift
import Foundation

func suareNumber(input: JSONDictionary, context: Context) -> JSONDictionary {
    guard let number = input["number"] as? Double else {
        return ["success": false]
    }

    log(context)
    log(ProcessInfo.processInfo.environment)

    let squaredNumber = number * number
    return ["success": true, "result": squaredNumber]
}

let runtime = try Runtime()
runtime.registerLambda("squareNumber", handler: suareNumber)
try runtime.start()