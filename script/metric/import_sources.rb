require File.expand_path('../../../config/environment',  __FILE__)
require 'colorize'
require 'json'
require 'byebug'
require 'rubygems'
require 'csv'

file_name = 'script/metric/data/sources.csv'

def create_company company
  return if Card.exists? company
  Card.create! name: company, type_id: Card::WikirateCompanyID
end

Card::Env[:protocol] = 'http://'
Card::Env[:host] = 'http://wikirate.org'
Card::Auth.current_id = Card.fetch_id 'Richard Mills'

Card::Auth.as_bot do
  Card::Env.params[:sourcebox] = 'true'
  CSV.foreach(file_name, encoding: 'windows-1251:utf-8',
                         headers: false) do |row|
    url = row[0]
    company = row[1]
    year = row[2]
    report_type = row[3]

    create_company company

    arg = { type_id: Card::SourceID,
            subcards: {
              '+Link' => { content: url },
              '+report_type' => report_type,
              '+date' => year
            } }
    puts arg.to_s.green
    Card.create! arg
  end
  Card::Env.params[:sourcebox] = 'false'
end
