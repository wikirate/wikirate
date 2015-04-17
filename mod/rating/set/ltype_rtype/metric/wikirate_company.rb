event :add_value, :before=>:approve, :on=>:update do
  if Env.params[:year]
    source_card = Card.create! :type_id=>Card::SourceID,:subcards=>{}.merge(subcards)
    @subcards = {
      "+#{Env.params[:year]}"=>{
        :type_id=>Card::MetricValueID, 
        :subcards=>{
          '+value'=>{:content=>Env.params[:value]},
          '+source'=>"[[#{source_card.name}]]"
        }}}
  end
end

format :html do
  view :all_values do |args|
    values = Card.search :left=>card.name, :type=>Card::MetricValueID
    values.map.with_index do |v, i|
      %{
        <span data-year=#{v.year} data-value=#{v.value} #{'style="display: none;"' if i > 0}>#{subformat(v).render_concise(args)}</span>
      }
    end
  end

  view :add_value do |args|
    years = Card.search :type=>'year'
    options = [["-- Select --",""]] + years.map{|x| [x.name,x.name]}
    year_tag = select_tag('year', options_for_select(options, years.first.name), :class=>'pointer-select form-control')
    value_tag = text_field_tag 'value', args[:pointer_item], :class=>'pointer-item-text form-control'
    card_form :update do
      wrap_each_with :div, :class=>'form-group' do
        [
          wrap_with(:div, "<label>Year</label>#{year_tag}".html_safe, :class=>'metric-value-year'),
          wrap_with(:div, "<label>Value</label>#{value_tag}".html_safe, :class=>'metric-value-value'),
        ]
      end.concat(_render_add_source(args)).concat  "#{ button_tag 'Add', :class=>'submit-button', :disable_with=>'Submitting' }"
    end
  end

  view :add_source do |args|
    source = Card.new :type_code=>:source
    subformat(source)._render_edit(args.merge(:hide=>'header help',:button=>""))
  #   file_source = Card.new :name=>'+file', :supercard=>source
  #   web_source = Card.new :type_code=>:uri
  #   direct_source = Card.new :type_code=>:basic
  #   @mode = :edit
  #   %{
  #   <div role="tabpanel" class="metric-source">
  #
  #     <!-- Nav tabs -->
  #     <ul class="nav nav-pills" role="tablist">
  #     <div class="btn-group" data-toggle="buttons">
  #       <li class="btn btn-primary active" data-toggle="tab" data-target="#home">
  #         <input type="radio" name="options" id="option1" autocomplete="off" checked>
  #         #{glyphicon 'globe'}
  #         </li>
  #       <li class="btn btn-primary" data-toggle="tab" data-target="#profile">
  #         <input type="radio" name="options" id="option2" value="profile" autocomplete="off">
  #         #{glyphicon 'open'}
  #       </li>
  #        <li class="btn btn-primary" data-toggle="tab" data-target="#messages">
  #         <input type="radio" name="options" id="option3" autocomplete="off">
  #         #{glyphicon 'pencil'}
  #       </li>
  #     </div>
  #     </ul>
  #
  #     <!-- Tab panes -->
  #     <div class="tab-content">
  #       <div role="tabpanel" class="tab-pane active" id="home">
  #         #{subformat(source).process_content '{{+link|editor}}'}
  #       </div>
  #       <div role="tabpanel" class="tab-pane" id="profile">
  #         #{subformat(file_source)._render_editor(args)}
  #       </div>
  #       <div role="tabpanel" class="tab-pane" id="messages">
  #         #{subformat(direct_source)._render_editor(args)}
  #       </div>
  #     </div>
  #
  #   </div>
  #
  #
  # }
  end
end
