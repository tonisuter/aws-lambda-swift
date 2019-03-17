import AWSLambdaSwift
import Splash

struct Input: Codable {
    let source: String
}

struct Output: Codable {
    let html: String
}

func highlightSyntax(input: Input, context: Context) -> Output {
    let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
    let html = highlighter.highlight(input.source)
    return Output(html: html)
}

let runtime = try Runtime()
runtime.registerLambda("highlightSyntax", handlerFunction: highlightSyntax)
try runtime.start()
