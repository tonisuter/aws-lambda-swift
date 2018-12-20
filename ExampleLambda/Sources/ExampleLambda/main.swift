import AWSLambdaSwift

func suareNumber(input: JSONDictionary) -> JSONDictionary {
    guard let number = input["number"] as? Double else {
        return ["success": false]
    }

    let squaredNumber = number * number
    return ["success": true, "result": squaredNumber]
}

let runtime = try Runtime()
runtime.registerLambda("squareNumber", handler: suareNumber)
try runtime.start()