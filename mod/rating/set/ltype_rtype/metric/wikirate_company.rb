event :debug_form, :before=>:approve, :on=>:update do
  @subcards = {"+#{Env.params[:year]}"=>{:type_id=>Card::MetricValueID, :subcards=>{'+value'=>{:content=>Env.params[:value]}}}}
end

format :html do
  view :add_value do |args|
    years = Card.search :type=>'year'
    options = [["-- Select --",""]] + years.map{|x| [x.name,x.name]}
    year_tag = select_tag('year', options_for_select(options, years.first.name), :class=>'pointer-select form-control')
    value_tag = text_field_tag 'value', args[:pointer_item], :class=>'pointer-item-text form-control'
    card_form :update do
      wrap_each_with :div, :class=>'form-group' do
        [
          (wrap_each_with :div, :class=>'col-sm-6' do
            [
              "<label>Year</label>#{year_tag}",
              "<label>Value</label>#{value_tag}"
            ]
          end),
        ]
      end.concat(nest(card.fetch(:trait=>:source, :new=>{}), :view=>:editor)).concat  "#{ button_tag 'Add', :class=>'submit-button', :disable_with=>'Submitting' }"
    end
  end
end