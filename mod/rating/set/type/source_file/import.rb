card_accessor :metric
card_accessor :year



event :validate_import, :before=>:approve, :on=>:update do
  if !(@metric = Env.params[:metric])
    errors.add :content, "Please give a metric."
  elsif !(metric = Card.fetch(Env.params[:metric])) or (metric.type_id != Card::WikirateMetricID)
    errors.add  :content, "Invalid metric"
  else
    @subcards['+metric'] = {:name=>Env.params[:metric]}
    @subcards['+year']   = {:name=>(Env.params[:year] || DateTime.now.year) ,:type=>'number'}
  end
end


event :import_csv, :after=>:store, :on=>:update do
  year = Env.params
  if Env.params[](metric_values = Env.params[:metric_values]) && metric_values.kind_of? Hash
    metric_values.each do |company, value|
      Card.create! :name=>"#{@metric}+#{company}+"
    end
  end
end

def csv_rows
  CSV.read(attach.path)
end


def clean_html? # return always true ;)
  false 
end


format :html do
  
  def render_row row
    file_company, value = row
    wikirate_company, status = matched_company(file_company) 
    checked =  [:partial, :exact].include? status
    checkbox = content_tag(:td) do
      check_box_tag "metric[#{wikirate_company}][]", value, checked, :disabled => (status==:none)
    end 
    [file_company, wikirate_company, status.to_s].inject(checkbox) do |row, item|
      row.concat content_tag(:td, item)
    end
  end
  
  def matched_company name
    if (company = Card.fetch(name)) && company.type_id == Card::WikirateCompanyID
      [name, :exact]
    elsif (result = Card.search :type=>'company', :name=>['match', name]) && !result.empty?
      [result.first.name, :partial]
    else
      Card.search(:type=>'company').each do |company|
        if name.match company.name
          return [company.name, :partial]
        end
      end
      ['', :none]
    end
  end
  
  
  def default_import_args args
    args[:buttons] = %{
      #{ button_tag 'Import', :class=>'submit-button', :disable_with=>'Submitting' }
      #{ button_tag 'Cancel', :class=>'cancel-button slotter', :href=>path, :type=>'button' }
    }
  end
  
  view :import do |args|
    frame_and_form :update, args do
      [
        _optional_render( :metric_select, args),
        _optional_render( :import_table, args ),
        _optional_render( :button_fieldset,   args )
      ]
    end
  end
  
  view :metric_select do |args|
    
  end
  
  view :import_table do |args|
    header = ['Select', 'Company in File', 'Company in Wikirate', 'Match']
    thead = content_tag :thead do
      content_tag :tr do
        header.map {|title|  content_tag(:th, title)}.join().html_safe
      end.html_safe
    end.html_safe
    #fields_for 'metric[]' , product do |product_fields|
    tbody = content_tag :tbody do
      card.csv_rows.collect { |elem| 
        concat content_tag(:tr, render_row(elem))
      }

    end.html_safe
    content_tag(:table, thead.concat(tbody)).html_safe
  end
end
