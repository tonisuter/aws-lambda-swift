import AWSLambdaSwift
import Splash

struct Event: Codable {
    let source: String
}

struct Result: Codable {
    let html: String
}

func highlightSyntax(event: Event, context: Context) -> Result {
    let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
    let html = highlighter.highlight(event.source)
    return Result(html: html)
}

let runtime = try Runtime()
runtime.registerLambda("highlightSyntax", handlerFunction: highlightSyntax)
try runtime.start()