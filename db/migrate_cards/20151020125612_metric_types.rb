# -*- encoding : utf-8 -*-

class MetricTypes < Card::Migration
  def metric_types_list
    %w( Researched Formula Score WikiRating ).map do |type|
      "[[#{type}]]"
    end.join "\n"
  end

  def up
    create_card! name: 'Metric type', type_id: Card::CardtypeID
    Card::Cache.reset_all
    create_metric_types %w(Researched WikiRating Formula Score)

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

    metric_type_plus_right_query =
      '{"right":"_right", "left":{' \
        '"type":"metric", "right_plus":["*metric type",{"refer_to":"_left"}]}}'
    create_card! name: '*metric type plus right',
                 codename: 'metric_type_plus_right'

    create_card! name: '*metric type plus right+*right+*structure',
                     type_id: Card::SetID,
                     content: metric_type_plus_right_query


    create_card! name: 'Metric type+*metric type+*type plus right+*structure',
                 type_id: Card::SetID,
                 content: '{"type":"metric",' \
                          '"right_plus":["*metric type",{"refer_to":"_left"}]}'

    import_json "production_export2.json"
    Card::Cache.reset_all
    update_existing_metrics
  end

  def create_metric_types names
    names.each do |name|
      create_card! name: name, codename: name.to_name.key, type: 'Metric type'
    end
  end

  def update_existing_metics
    Card.search(type_id: Card::MetricID, return: 'name').each do |metric|
      create_card name: "#{metric}+*metric type",
                  type_id: Card::PointerID,
                  content: '[[Researched]]',
                  silent_change: true
    end
  end
end
