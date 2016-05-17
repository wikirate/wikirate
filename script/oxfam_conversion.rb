#!/usr/bin/env ruby

require "roo"
require "csv"

SPREADSHEET_DIR = "/Users/ethan/Documents/ratings"
SPREADSHEET_FILENAME = "#{SPREADSHEET_DIR}/oxfam_scorecard.xlsx"

xlsx = Roo::Excelx.new(SPREADSHEET_FILENAME)

SHEETS = ["Overview", "Land", "Women", "Transparency", "Farmers", "Water", "Workers", "Climate Change", "Release Notes"]

# IMPORTANT: row counting starts with 1, column counting starts with 0

METRIC_CODE_COL = 0
METRIC_Q_COL = 1

MAP = {
  "Land" => {
    header_rows: 6,
    company_row: 4,
    intro_columns: 2,          # how many columns before you get to a country section
    columns_per_company: 7,    # include blanks
    value_columns: [3, 1],      # score is 4th, rating is 2nd.  take first one with a value
    source_columns: 4,
    metric_description: 5
  }
}

SHEETS_TO_IMPORT = [1]

SHEETS_TO_IMPORT.each do |sheetnum|
  sheetname = SHEETS[sheetnum]
  sheet = xlsx.sheet(sheetname)

  smap = MAP[sheetname]
  companies = sheet.row(smap[:company_row]).compact

  cmap = {}
  companies.each_with_index do |company, cidx|
    start = smap[:intro_columns] + (smap[:columns_per_company] * cidx)
    cmap[company] = {
      start: start,
      value: smap[:value_columns].map { |c| start + c },
      source: smap[:source_columns] + start
    }
  end

  puts "companies = #{companies}"

  for row_idx in (smap[:header_rows] + 1)..sheet.last_row
    row = sheet.row(row_idx)
    metric_code = row[METRIC_CODE_COL]
    next if metric_code.nil?
    metric_question = row[METRIC_Q_COL]

    puts "\nMETRIC - (code:#{metric_code}, row:#{row_idx}) #{metric_question}"
    companies.each do |company|
      value_col = cmap[company][:value].find { |col| row[col] }
      if value_col
        value = row[value_col]
        source = row[cmap[company][:source]]
        puts "  #{company} => #{value}#{" - source: #{source}" if source}"
      else
        puts "  #{company} => (VALUE NOT FOUND)"
      end
    end
  end
end

# def col name
#   COLUMNS.index(name)
# end
#
# def groupname row, column_idx
#   "#{ COL_ABBRS[ column_idx ] }: #{ row[ column_idx ] }"
# end
