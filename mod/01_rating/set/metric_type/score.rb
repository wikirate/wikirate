include Set::Abstract::Calculation

card_accessor :formula, type: 'pointer'

def scorer
  cardname.tag
end

def basic_metric
  left
end

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
  # view :methodology_tab do
  #   <<-HTML
  #     <div class="row">
  #           			<div class="row-data">
  #                   {{+Unit|titled;title:Unit}}
  #                 </div>
  #   <div class="row-data">
  #     {{+Range|titled;title:Range}}
  #   </div>
  #                 <div class="row-data">
  #                   {{+Methodology|titled;title:Methodology}}
  #                 </div>
  #   </div>
  #   HTML
  # end

  def name_field form=nil, options={}
    form ||= self.form
    option_names =
      Card.search type_id: MetricID,
                  right_plus: [
                    '*metric type',
                    content: ['in', '[[Formula]]','[[Researched]]']
                  ],
                  sort: 'name', return: :name


      # name_card = Card.new name: 'name', type_id: PointerID,
      #                        subcards: {
      #                          '+*input' => '[[select]]',
      #                          '+*options' => {
      #                            type_id: SearchTypeID,
      #                            content: '{"type":"metric"}'
      #                          }
      #                        }
    options = [['-- Select --', '']] + option_names.map { |x| [x, x] }
    editor_wrap :card do
      hidden_field_tag('card[subcards][+metric][content]',
                       option_names.first,
                       class: 'card-content') +
        select_tag('pointer_select',
                   options_for_select(options, option_names.first),
                   class: 'pointer-select form-control')
    end
    # subformat(name_card)._render_select
  end

  def default_thumbnail_subtitle_args args
    args[:text] ||= 'scored by'
    args[:author] ||= card.scorer
end
end

event :set_scored_metric_name, :initialize,
      on: :create do
  return if cardname.parts.size >= 3
  metric = (mcard = remove_subfield(:metric)) && mcard.item_names.first
  self.name = "#{metric}+#{Auth.current.name}"
end

event :default_formula, :prepare_to_store,
      on: :create do
  add_subfield :formula, content: "{{#{basic_metric.name}}}",
                         type_id: PlainTextID
end
