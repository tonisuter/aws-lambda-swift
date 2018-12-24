import AWSLambdaSwift
import Foundation

/*func squareNumber(input: JSONDictionary, context: Context) -> JSONDictionary {
    guard let number = input["number"] as? Double else {
        return ["success": false]
    }

    log(context)
    log(ProcessInfo.processInfo.environment)

    let squaredNumber = number * number
    return ["success": true, "result": squaredNumber]
}*/

struct Input: Codable {
    let number: Double
}

struct Output: Codable {
    let result: Double
}

func squareNumber(input: Input, context: Context) -> Output {
    let squaredNumber = input.number * input.number
    return Output(result: squaredNumber)
}

let runtime = try Runtime()
runtime.registerLambda("squareNumber", handlerFunction: squareNumber)
try runtime.start()