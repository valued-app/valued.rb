require "bundler/setup"
require "sinatra"
require "sinatra/cors"
require "rouge"

shell_formatter = Rouge::Formatters::Terminal256.new
lexer = Rouge::Lexers::JSON.new

set :allow_origin, "*"
set :allow_methods, "POST,OPTIONS"
set :allow_headers, "Authorization, Content-Type"

post "/events" do
  data   = JSON.load(request.body.read)
  pretty = JSON.pretty_generate(data)
  puts shell_formatter.format(lexer.lex(pretty))
  status 204
end
