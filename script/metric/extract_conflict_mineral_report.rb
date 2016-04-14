require File.expand_path('../../../config/environment',  __FILE__)
require 'colorize'
require 'json'
require 'byebug'
require 'rubygems'
require 'csv'

file_name = 'script/metric/data/certh.json'

text = File.open(file_name).read

begin
  json_array = JSON.parse(text)
  json_array.each do |json_obj|
    snippets = json_obj['Snippets'][0]
    company = json_obj['Company_name']
    snippets.each do |value|
      next if value['name'] != 'Conflict Minerals Report'
      cite_year = value['citeyear']
      url = value['value']
      puts "#{company},#{url},#{cite_year}".green
    end
  end
end
