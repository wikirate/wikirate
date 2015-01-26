require 'roo'
require 'csv'


SHEETS = ["Overview", "Land", "Women", "Transparency", "Farmers", "Water", "Workers", "Climate Change", "Release Notes"]

event :import_sheet, :after=>:store, :on=>:update do
  if Env.params[:sheet] and SHEETS.include? Env.params[:sheet]
    sheet = Sheet.new self, Env.params[:sheet]
    begin
      import_oxfam_data sheet
    rescue => e
      errors.add :import_failed, e.message
      raise e
    end
  end
end

def import_oxfam_data sheet
  sheet.metrics.each do |metric|
    metric.save! 
    metric.save_values! :limit=>20
  end
end

format :html do
  view :import do |args|
    frame do
        Card::Set::Self::OxfamSpreadsheet::SHEETS.map do |name|
        link_to "Import #{name}", path(:action=>:update, :sheet=>name), :method=>:post
      end.map {|link| "<p>#{link}</p>" }.join
    end
  end
end




class Sheet
  attr_reader :metrics, :companies
  
  MAP = {
    'DEFAULT' => {
      :header_rows => 6,
      :company_row => 4,
      :intro_columns => 2,          # how many columns before you get to a country section   
      :columns_per_company => 6,    # include blanks
      :metric_description => false,
      :has_value_if_metric => 0,     # to exlcude non-metric rows
      :metric_weight => 3,
    },
    'Land' => { 
      :columns_per_company => 7,    
      :metric_description => true
    },
    'Farmers' => { 
      :columns_per_company => 7,    
      :metric_description => true
    },
    'Climate Change' => {
      :intro_columns => 5,
      :columns_per_company => 8,
      :metric_weight => 5
    }
  }
  
  def initialize filecard, sheetname, year=2014
    @category  = sheetname
    path = filecard.attach.path
    xlsx = Roo::Excelx.new(path)
    @sheet     = xlsx.sheet(@category)
    @sheet_map = MAP['DEFAULT'].merge(MAP[@category])
  
    @companies = @sheet.row( @sheet_map[:company_row] ).compact
    load_metrics year, filecard.name
  end
  
  private
  
  def each_metric_row_with_index
     for row_idx in (@sheet_map[:header_rows]+1)..(@sheet.last_row)
       row = @sheet.row(row_idx)
       if row[@sheet_map[:has_value_if_metric]]
         yield(row, row_idx)
       end
     end
  end
  
  
  def load_metrics year, sourcename
    company_offset = {} 
    @companies.each_with_index do |company, cidx|
      start = @sheet_map[:intro_columns] + ( @sheet_map[:columns_per_company] * cidx )
      company_offset[company] = start
    end
    
    @metrics = []
    each_metric_row_with_index do |row, row_idx|
      @metrics << OxfamMetric.new(row, row_idx, @sheet_map[:metric_description], @sheet_map[:metric_weight], company_offset, year, sourcename) 
    end
    
    @metrics.each do
      
    end
    
  end
end


class OxfamMetric
  attr_reader :companies, :code, :question, :values
  attr_accessor :submetrics
  
  MAP = {                  # column indices
          :code => 0,
          :question => 1,
          :description => 8,
          :weight  => 3
        }
  
  def initialize row, row_index, description, weight_col, company_offset, year, sourcename
    @code        = row[MAP[:code]].strip
    @question    = row[MAP[:question]].strip
    @weight      = row[weight_col]
    @year        = year
    @row_index   = row_index
    @description = description ? row[MAP[:description]] : nil
    @sourcename  = sourcename
    @submetrics  = {}
    @values = []
    company_offset.each do |company, offset|
      @values << Value.new(row, company, offset)
    end
  end

  
  def cardname
    "Oxfam+#{@code}"
  end
  
  def save!
    Card.create! :name=>cardname, :type=>'metric', :subcards=>{
     '+code'     => @code,
     '+question' => @question,
     '+description' => @description,
    }
  end

  def save_values! opts
    cnt = 0
    @values.each do |value|
      if opts[:limit] && cnt > opts[:limit]
        break
      end
      
      value_cardname = "#{cardname}+#{value.company}+#{@year}"    
      source_pages = Array.wrap(value.links).map do |uri|
        page = if (dups=Webpage.find_duplicates(uri).first) 
            dups.left 
          else
            Card.create! :type_code=>:webpage, :subcards=>{"+#{Card[:wikirate_link].name}"=>{:content=>uri}}
          end
        page.name
      end
      source_pages << @sourcename
      source_content = source_pages.map {|cardname| "[[#{cardname}]]"}.join "\n" 
      subcards = {
        '+source' => {:content=>source_content, :type_id=>PointerID},
      }
      Card.create! :name=>value_cardname, :content=>value.measurement.to_s, :subcards=>subcards
      cnt += 1
    end
  end
end



class Value
  attr_reader :company, :measurement, :links

  MAP = {             # column indices relative to first company column
    :weight    => 0, 
    :answer    => 1,
    :subscore  => 2,
    :score     => 3,
    :reference => 4,
  }

  VALUE_COLUMNS  = [:score, :answer]    
  
  def initialize row, company, company_offset
    @company = company
    @data = {}
    MAP.each do |col_name, col_offset|
      index = company_offset + col_offset
      @data[col_name] = row[index] 
    end
    if @data[:reference]
      @data[:links] = []
      @data[:reference].scan %r(http://\S+) do |match|
        binding.pry unless match
        @data[:links] << match
      end
    end
    @links = @data[:links]
    @measurement = VALUE_COLUMNS.find { |col_name| @data[col_name] }
  end

end




