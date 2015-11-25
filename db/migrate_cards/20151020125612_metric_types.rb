# -*- encoding : utf-8 -*-

class MetricTypes < Card::Migration
  def metric_types_list
    %w( Researched Formula Score WikiRating ).map do |type|
      "[[#{type}]]"
    end.join "\n"
  end

  def up
    create_card! name: 'Researched', codename: 'researched'
    create_card! name: 'Calculation', codename: 'calculation'
    create_card! name: 'WikiRating', codename: 'wiki_rating'
    create_card! name: 'Formula', codename: 'formula'
    create_card! name: 'Score', codename: 'score'

    create_card! name: '*metric type', codename: 'metric_type',
                 subcards: {
                   '+*right+*default' => {
                     type_id: Card::PointerID,
                     content: '[[Researched]]'
                   },
                   '+*right+*options' => {
                     type_id: Card::PointerID,
                     content: metric_types_list
                   },
                   '+*right+*input' => {
                     content: 'radio'
                   }
                 }

    create_card! name: '*metric type plus right',
                 codename: 'metric_type_plus_right'
    create_card! name: 'Basic+*metric type+*type plus right+*structure',
                 type_id: Card::SetID,
                 content: '{"type":"metric",' \
                          '"right_plus":["*metric type",{"refer_to":"_left"}]}'
  end
end
