# require 'roo'
# require 'csv'

# SHEETS = ["Land", "Women", "Transparency", "Farmers", "Water", "Workers", "Climate Change"]

# event :import_sheet, :after=>:store, :on=>:update do
#   if Env.params[:sheet] and SHEETS.include? Env.params[:sheet]
#     sheet = Sheet.new self, Env.params[:sheet]
#     begin
#       import_oxfam_data sheet
#     rescue => e
#       errors.add :import_failed, e.message
#       raise e
#     end
#   end
# end

# def import_oxfam_data sheet
#   #cnt = 0
#   sheet.metrics.each do |code, metric|
#     #cnt += 1
#     #break if cnt > 5
#     metric.save!
#     metric.save_values!
#   end
# end

# format :html do
#   view :import do |args|
#     frame do
#         Card::Set::Self::OxfamSpreadsheet::SHEETS.map do |name|
#         link_to "Import #{name}", path(:action=>:update, :sheet=>name), :method=>:post
#       end.map {|link| "<p>#{link}</p>" }.join
#     end
#   end
# end

# class Sheet
#   attr_reader :metrics, :companies
#   METRIC_MAP = {
#     'DEFAULT' => {
#       :code => 0,
#       :question => 1,
#       :weight  => 2,
#       :description => false,
#       :is_score => 5
#     },
#     'Land' => {
#       :description => 8
#     },
#     'Farmers' => {
#       :description => 8
#     },
#     'Climate Change' => {
#       :weight => 4,
#       :is_score => 8
#     }
#   }

#   MAP = {
#     'DEFAULT' => {
#       :header_rows => 6,
#       :company_row => 4,
#       :intro_columns => 2,          # how many columns before you get to a country section
#       :columns_per_company => 6,    # include blanks
#     },
#     'Land' => {
#       :columns_per_company => 7,
#     },
#     'Farmers' => {
#       :columns_per_company => 7,
#     },
#     'Climate Change' => {
#       :intro_columns => 5,
#       :columns_per_company => 8,
#     }
#   }

#   def initialize filecard, sheetname, year=2014
#     @category  = sheetname
#     path = filecard.attach.path
#     xlsx = Roo::Excelx.new(path)
#     @sheet      = xlsx.sheet(@category)
#     @sheet_map  = MAP['DEFAULT'].merge(MAP[@category] || {})
#     @metric_map = METRIC_MAP['DEFAULT'].merge(METRIC_MAP[@category] || {})

#     @companies = @sheet.row( @sheet_map[:company_row] ).compact
#     load_metrics year, filecard.name
#   end

#   private

#   def method_missing name, *args
#     col=@metric_map[name]
#     case col
#     when nil
#       super
#     when false
#       ''
#     else
#       res = if args.size == 1
#           @sheet.row(args[0])[col]
#         else
#           @row[col]
#         end
#       if res && name == :code
#         res.to_s.sub(/^(\D+)\.(\d)/, '\1\2').strip  # the regex fixes a typo in the workers sheets (W.1.2 instead of W1.2)
#       else
#         res
#       end
#     end
#   end

#   def each_metric_row_with_index
#     for row_idx in (@sheet_map[:header_rows]+1)..(@sheet.last_row)
#       if code(row_idx)
#         @row = @sheet.row(row_idx)
#         yield(@row, row_idx)
#       end
#     end
#   end

#   def load_metrics year, sourcename
#     company_offset = {}
#     @companies.each_with_index do |company, cidx|
#       start = @sheet_map[:intro_columns] + ( @sheet_map[:columns_per_company] * cidx )
#       company_offset[company] = start
#     end

#     @metrics = {}
#     each_metric_row_with_index do |row, row_idx|
#       desc = if question(row_idx+1) && !code(row_idx+1)
#                question(row_idx+1)
#              else
#                description(row_idx)
#              end

#       metric =  OxfamMetric.new(row, company_offset,
#           :code=>code,
#           :question=>question,
#           :description=>desc,
#           :year=>year,
#           :weight=>weight,
#           :sourcename=>sourcename,
#           :row_index=>row_idx,
#           :is_score=>!!is_score
#         )
#       @metrics[metric.code] = metric
#       digits = metric.code.split '.'
#       if digits.size > 1
#         digits.pop
#         code = digits.join '.'
#         @metrics[code].add_submetric metric if @metrics[code]
#       end
#     end
#   end
# end

# class OxfamMetric
#   attr_reader :companies, :submetrics

#   def initialize row, company_offset, data
#     @data = data
#     @submetrics  = []
#     @values = []
#     company_offset.each do |company, offset|
#       begin
#         @values << Value.new(row, company, offset)
#       rescue RuntimeError => e # No Value
#       end
#     end
#   end

#   def method_missing name, *args
#     @data[name]
#   end

#   def cardname
#     shortname = if is_score && question.length < 100
#                   "#{question} (#{code})"
#                 else
#                   code
#                 end
#     "Oxfam+#{ shortname.strip }"
#   end

#   def save!
#     formula = @submetrics.map do |submetric|
#       "(#{submetric.weight}) * [[#{submetric.name}]]"
#     end

#     list = @submetrics.map do |submetric|
#       format =  if submetric.submetrics.present?
#           "{{%s+methodology|closed;title:0-%s %s;hide:closed_content,menu;show:title_link}}"
#         else
#           "{{%s|closed;title:0-%s %s;hide:toggle,menu;show:title_link}}"
#         end
#       text = format % [submetric.name, submetric.weight.round(2).to_s.chomp('.0'), submetric.question]
#       "<li>#{text}</li>"
#     end.join "\n"

#     desc = if formula.present?
#         %{
#           #{description}
#           <p>
#           Sum of
#           <ul>
#           #{list}
#           </ul>
#           </p>
#         }
#       else
#         description
#       end

# #    Rails.logger.info "\n\n\nMetric: #{cardname}, code: #{code}, question: #{question}, desc: #{desc}\n\n\n"

#     Card.create! :name=>cardname, :type=>'metric', :subcards=>{
#      '+code'        => code,
#      '+about'       => question,
#      '+question'    => question,
#      '+methodology' => desc,
#      '+formula'     => {:content=>formula.join("\n"), :type=>'pointer'},
#      '+submetrics'  => {:content=>@submetrics.map { |sm| "[[#{sm.name}]]" }.join("\n"), :type=>'pointer'}
#     }
#   end

#   def save_values!
#     @values.each do |value|
#       value_cardname = "#{cardname}+#{value.company}+#{year}"
#       #puts "save #{value_cardname}"
#       source_pages = Array.wrap(value.links).map do |uri|
#         page = if (dups=Webpage.find_duplicates(uri).first)
#                  dups.left
#                else
#                  Card.create! :type_code=>:source, :subcards=>{"+#{Card[:wikirate_link].name}"=>{:content=>uri}}
#                end
#         page.name
#       end
#       source_pages << sourcename
#       source_content = source_pages.map {|cardname| "[[#{cardname}]]"}.join "\n"
#       subcards = {
#         '+source' => {:content=>source_content, :type_id=>PointerID},
#         '+value'  => {:content=>value.measurement.to_s, :type_id=>PhraseID}
#       }
#       Card.create! :name=>value_cardname,:subcards=>subcards
#     end
#   end

#   def add_submetric metric
#     @submetrics << metric
#   end
# end

# class Value
#   attr_reader :company, :measurement, :links

#   MAP = {             # column indices relative to first company column
#     :answer    => 1,
#     :subscore  => 2,
#     :score     => 3,
#     :reference => 4,
#   }

#   COMPANY_CARDNAME = {
#     'Associated British Foods' => 'Associated British Foods plc',
#     'Coca Cola' =>                'Coca Cola Company',
#     'Danone' =>                   'Groupe Danone',
#     'Kellogg' =>                  "Kellogg's",
#     'Mars' =>                     'Mars Inc.',
#     'Mondelez' =>                 'Mondelēz International',
#     'PepsiCo' =>                  'PepsiCo Inc.',
#   }
#   VALUE_COLUMNS  = [:answer, :score]

#   def initialize row, company, company_offset
#     @company = COMPANY_CARDNAME[company] || company
#     @data = {}
#     MAP.each do |col_name, col_offset|
#       index = company_offset + col_offset
#       @data[col_name] = row[index]
#     end
#     if @data[:reference]
#       @data[:links] = []
#       @data[:reference].scan %r(http://[^\s\u00a0]+) do |match|
#         @data[:links] << match
#       end
#     end
#     @links = @data[:links]
#     @measurement = VALUE_COLUMNS.inject(nil) do |res,col_name|
#         (res == '-' && @data[col_name]) || res || @data[col_name]
#       end
#     if !@measurement || @measurement == '-' || !@measurement.present?
#       raise RuntimeError, "No value for #{company}"
#     end
#     if @measurement.kind_of? Float
#       @measurement = @measurement.round(2).to_s.chomp('.0')
#     end
#   end

# end
