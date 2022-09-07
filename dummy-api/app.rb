require "bundler/setup"
require "sinatra"
require "rouge"

shell_formatter = Rouge::Formatters::Terminal256.new
lexer = Rouge::Lexers::JSON.new

post "/events" do
  data   = JSON.load(request.body.read)
  pretty = JSON.pretty_generate(data)
  puts shell_formatter.format(lexer.lex(pretty))
  status 204
end