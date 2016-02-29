include Set::Abstract::Calculation

def normalize_value value
  return 0 if value < 0
  return 10 if value > 10
  value
end

  view :select do |_args|
    options = [['-- Select --', '']] + card.option_names.map { |x| [x, x] }
    select_tag('pointer_select',
               options_for_select(options, card.item_names.first),
               class: 'pointer-select form-control'
              )
  end


format :html do
  def name_field form=nil, options={}
    form ||= self.form
    option_names =
      Card.search type_id: MetricID, sort: 'name', return: :name


      # name_card = Card.new name: 'name', type_id: PointerID,
      #                        subcards: {
      #                          '+*input' => '[[select]]',
      #                          '+*options' => {
      #                            type_id: SearchTypeID,
      #                            content: '{"type":"metric"}'
      #                          }
      #                        }
    options = [['-- Select --', '']] + option_names.map { |x| [x, x] }
    select_tag 'pointer_select',
               options_for_select(options, option_names.first),
               class: 'pointer-select form-control'
    # subformat(name_card)._render_select
  end
end