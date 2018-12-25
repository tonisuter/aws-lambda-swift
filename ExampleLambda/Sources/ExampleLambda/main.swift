import AWSLambdaSwift
import Splash

enum Example1 {
    struct Event: Codable {
        let number: Double
    }

    struct Result: Codable {
        let result: Double
    }

    static func squareNumber(event: Event, context: Context) -> Result {
        let squaredNumber = event.number * event.number
        return Result(result: squaredNumber)
    }
}

enum Example2 {
    struct Event: Codable {
        let source: String
    }

    struct Result: Codable {
        let html: String
    }

    static func highlight(event: Event, context: Context) -> Result {
        let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
        let html = highlighter.highlight(event.source)
        return Result(html: html)
    }
}

let runtime = try Runtime()
runtime.registerLambda("squareNumber", handlerFunction: Example1.squareNumber)
runtime.registerLambda("highlight", handlerFunction: Example2.highlight)
try runtime.start()