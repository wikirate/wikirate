def value_name
  if (metric_name = cardname.left) && Env.params[:year] && company_name = subcards.delete("#{metric_name}+add value company")
    company = Card.new company_name
    "#{metric_name}+#{company.item_names.first}+#{Env.params[:year]}"
  end
end


format :html do
  view :core do |args|
    company_tag = ""
    company_card = Card.fetch card.cardname.left+"+add value company",:new=>{}
    with_inclusion_mode :edit do
      source = Card.new :type_code=>:source
      company_tag += subformat(company_card)._render_content_formgroups(args.merge(:hide=>'header help',:buttons=>""))
      company_tag += company_card.format.form_for_multi.hidden_field :type_id
    end
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