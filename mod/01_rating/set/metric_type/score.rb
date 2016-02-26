include Set::Abstract::Calculation

def normalize_value value
  return 0 if value < 0
  return 10 if value > 10
  value
end


format :html do
  def name_field form=nil, options={}
    form ||= self.form
    name_card = Card.new name: 'name', type_id: PointerID,
                           subcards: {
                             '+*input' => '[[select]]',
                             '+*options' => {
                               type_id: SearchTypeID,
                               content: '{"type":"metric"}'
                             }
                           }

    subformat(name_card)._render_select
  end
end
