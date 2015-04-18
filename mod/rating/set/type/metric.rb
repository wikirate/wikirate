card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"


format :html do
  view :legend do |args|
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
        "/#{range.raw_content}"
    else
      ''
    end
  end

  view :add_value do |args|
    companies = Card.search :type=>'company'
    c_options = [["-- Select --",""]] + companies.map{|x| [x.name,x.name]}
    company_tag = select_tag('year', options_for_select(c_options, companies.first.name), :class=>'pointer-select form-control')
    years = Card.search :type=>'year'
    y_options = [["-- Select --",""]] + years.map{|x| [x.name,x.name]}
    year_tag = select_tag('year', options_for_select(y_options, years.first.name), :class=>'pointer-select form-control')
    value_tag = text_field_tag 'value', args[:pointer_item], :class=>'pointer-item-text form-control'
    card_form :update do
      wrap_each_with :div, :class=>'form-group' do
        [
          wrap_with(:div, "<label>Company</label>#{company_tag}".html_safe, :class=>'metric-value-company'),
          wrap_with(:div, "<label>Year</label>#{year_tag}".html_safe, :class=>'metric-value-year'),
          wrap_with(:div, "<label>Value</label>#{value_tag}".html_safe, :class=>'metric-value-value'),
        ]
      end.concat(_render_add_source(args)).concat  "#{ button_tag 'Add', :class=>'submit-button', :disable_with=>'Submitting' }"
    end
  end

  view :add_source do |args|
    source = Card.new :type_code=>:source
    subformat(source)._render_edit(args.merge(:hide=>'header help_text', :buttons=>''))
  end
end
