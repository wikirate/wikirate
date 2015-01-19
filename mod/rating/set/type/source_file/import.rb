

event :import_csv, :after=>:store, :on=>:update do
    
end




def match_company name
  if (company = Card.fetch(name)) && company.type_id == Card::WikirateCompanyID
    [name, name, :exact]
  elsif (result = Card.search :type=>'company', :name=>['match', name]) && !result.empty?
    [name, result.first.name, :partial]
  else
    [name, '', :none]
  end
end

def each_row path
  CSV.foreach(path) do |row|
    yield(row)
  end
end

def render_row row, status
  checked =  [:partial, :exact].include? status 
  contant_tag(:td) do
    check_box_tag "select_checkbox", "add", checked, :class=>'pointer-checkbox-button'
  end + match_company(row[0]).map do |item|
    content_tag(:td, item)
  end.join
end

format :html do
  view :import_data do |args|
    header = ['Select', 'Company in File', 'Company in Wikirate', 'Match']
    thead = content_tag :thead do
      content_tag :tr do
        header.map {|title|  content_tag(:th, title)}.join().html_safe
      end
    end

    # tbody = content_tag :tbody do
    #  each_row(path) do |row|
    #    content_tag :tr=>{ render_row(row) }
    #  end.join().html_safe
    # end

    content_tag :table, thead.concat(tbody)
  end
end