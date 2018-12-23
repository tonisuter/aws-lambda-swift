import AWSLambdaSwift

func suareNumber(input: JSONDictionary, context: Context) -> JSONDictionary {
    guard let number = input["number"] as? Double else {
        return ["success": false]
    }

    log(context)

    let squaredNumber = number * number
    return ["success": true, "result": squaredNumber]
}

let runtime = try Runtime()
runtime.registerLambda("squareNumber", handler: suareNumber)
try runtime.start()