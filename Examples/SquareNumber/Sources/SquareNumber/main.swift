import AWSLambdaSwift

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
do {
    let runtime = try Runtime()
    runtime.registerLambda("squareNumber", handlerFunction: squareNumber)
    try runtime.start()
} catch (let error) {
    log(error)
}
