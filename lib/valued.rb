require "concurrent"
require "json"
require "net/http"

module Valued
  require "valued/connection"
  require "valued/global"
  require "valued/scope"
  extend Global
end