require "rubygems"
require "json"
require "byebug"
require "net/http"
require "uri"

 # http://160.40.51.30:8080/WikiRateAPI/Snippets?perPageDocs=10000&page=1

 # source name, snippet name = value, company name, source link

 full_json = ""
 puts "Start getting the json"
for i in 1..5

  puts "\r"
  puts i
  uri = URI.parse("http://160.40.51.30:8080/WikiRateAPI_NEW/Snippets?perPageDocs=10000&page=#{i}")
  response = Net::HTTP.get_response(uri)
  snippet = response.body
  break if snippet == "[]"

  snippet[-1] = ""
  snippet[0] = "," if i != 1

  full_json += "#{snippet}\n"

end
# full_json[full_json.rindex]=""
# remove the last comma
full_json.sub!(/(.*),/, '\1,')
full_json += "]"
File.open("script/metric/data/certh.json", "w") { |file| file.write(full_json) }
