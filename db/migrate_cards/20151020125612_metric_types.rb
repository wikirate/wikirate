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
                   '+*right+*default' => { type_id: Card::PointerID},
                   '+*right+*options' => {
                     type_id: Card::PointerID,
                     content: metric_types_list
                   },
                   '+*right+*input' => {
                     content: 'radio'
                   }
                 }
    create_card! name: '*metric method', codename: 'metric_method'
    create_card! name: '*calculation type', codename: 'calculation_type'
  end
end
