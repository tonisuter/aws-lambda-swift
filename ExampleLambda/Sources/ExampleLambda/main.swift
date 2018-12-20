import AWSLambdaSwift

func lambda(input: JSONDictionary) -> JSONDictionary {
    print(input)
    return ["hello": "world", "number": 42, "strings": ["one", "two", "three"]]
}

let runtime = try Runtime()
runtime.registerLambda("lambda", handler: lambda)
try runtime.start()