require File.expand_path('../../../config/environment',  __FILE__)
require File.expand_path('../../wikirate_import_shared', __FILE__)

require 'colorize'
require 'json'
require 'rubygems'
require 'csv'

file_name = 'script/metric/data/sources.csv'

def create_company company
  return if Card.exists? company
  Card.create! name: company, type_id: Card::WikirateCompanyID
end

def create_source row
  url = row[0]
  company = row[1]
  year = row[2]
  report_type = row[3]
  arg = { type_id: Card::SourceID,
          subcards: {
            '+Link' => { content: url },
            '+report_type' => report_type,
            '+date' => year,
            '+company' => "[[#{company}]]"
          } }
  puts arg.to_s.green
  Card.create! arg
end

Card::Auth.as_bot do
  silent_mode do
    Card::Env.params[:sourcebox] = 'true'
    CSV.foreach(file_name, encoding: 'windows-1251:utf-8',
                           headers: false) do |row|
      create_company row[1]
      create_source row
    end
  end
end
