def value_name
  if (metric_name = cardname.left) && Env.params[:company] && Env.params[:year]
    "#{metric_name}+#{Env.params[:company]}+#{Env.params[:year]}"
  end
end


format :html do
  view :core do |args|
    companies = Card.search :type=>'company', :sort=>'name'
    c_options = [["-- Select --",""]] + companies.map{|x| [x.name,x.name]}
    company_tag = select_tag('company', options_for_select(c_options, companies.first.name), :class=>'pointer-select form-control')
    years = Card.search :type=>'year', :sort=>'name', :dir=>'desc'
    y_options = [["-- Select --",""]] + years.map{|x| [x.name,x.name]}
    year_tag = select_tag('year', options_for_select(y_options, years.first.name), :class=>'pointer-select form-control')
    value_tag = text_field_tag 'value', args[:pointer_item], :class=>'pointer-item-text form-control'
    card_form :update, :hidden=>{:success=>{:id=>"#{card.cardname.left}+right sidebar",:view=>:content}} do
      wrap_each_with :div, :class=>'form-group' do
        [
          wrap_with(:div, "<label>Company</label>#{company_tag}".html_safe, :class=>'metric-value-company'),
          wrap_with(:div, :class=>'row') do [
            wrap_with(:div, "<label>Year</label>#{year_tag}".html_safe, :class=>'metric-value-year col-xs-2'),
            wrap_with(:div, "<label>Value</label>#{value_tag}".html_safe, :class=>'metric-value-value col-xs-10'),
            ]
          end
        ]
      end.concat(_render_add_source(args))
    end
  end
end