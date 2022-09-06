require "yard"

Dir.glob("valued-*") do |lib|
  task docs: "docs:#{lib}"
  YARD::Rake::YardocTask.new("docs:#{lib}") do |t|
    t.files   = ["#{lib}/lib/**/*.rb"]
    t.options = ["--no-cache", "-o", "docs/#{lib}", "-r", "#{lib}/README.md"]
  end
end