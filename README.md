# aws-lambda-swift

The goal of this project is to implement a custom AWS Lambda Runtime for the Swift programming language.

### Step 1: Implement your lambda handler function
`ExampleLambda` is an SPM package with a single, executable target that implements the lambda handler function.
This package depends on the `AWSLambdaSwift` package which produces a library that contains the actual runtime.
In the main.swift file of the `ExampleLambda` executable we import the AWSLambdaSwift library, instantiate the
`Runtime` class and then register our handler function. Finally, we start the runtime:

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

At the moment, the handler functions need to have a single parameter of type `JSONDictionary` and they also need to
return a `JSONDictionary`. This type is just a typealias for the type `Dictionary<String, Any>`.

### Step 2: Build the lambda


### Step 3: Setup the layer

### Step 4: Setup the lambda