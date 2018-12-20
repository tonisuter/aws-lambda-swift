import AWSLambdaSwift

func lambda1(input: JSONDictionary) -> JSONDictionary {
    log(input)
    return ["hello": "world", "number": 42, "strings": ["one", "two", "three"]]
}

func lambda2(input: JSONDictionary) -> JSONDictionary {
    log(input)
    return ["result": "success"]
}

let runtime = try Runtime()
runtime.registerLambda("lambda1", handler: lambda1)
runtime.registerLambda("lambda2", handler: lambda2)
try runtime.start()