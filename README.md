# aws-lambda-swift

The goal of this project is to implement a custom AWS Lambda Runtime for the Swift programming language.

1. Create a package with an executable target that depends on AWSLambdaSwift
2. Implement your lambda function:

Usage:

```swift
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
```

3. Setup the layer


4. Setup the lambda