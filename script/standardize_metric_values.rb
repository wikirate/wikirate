require File.expand_path('../../config/environment', __FILE__)

def standardize_numeric_metric_values metric_name
  metric_values = Card.search type_id: Card::MetricValueID,
                              left: {
                                left: metric_name
                              },
                              append: 'value'
  metric_values.each do |mv|
    content = mv.content
    content.delete!(',')
    if !content =~ /[0-9\.]+/
      puts "#{mv.name}'s value cannot be casted as number.".red
    else
      mv.content = content
      puts "saving #{mv.name} as #{content}".green
      # binding.pry
      mv.save!
    end
  end
end

def standardize_currency_metric_values metric_name
  metric_values = Card.search type_id: Card::MetricValueID,
                              left: {
                                left: metric_name
                              },
                              append: 'value'
  metric_values.each do |mv|
    content = mv.content
    # sample case $11.4 B, $-23.4 B
    # Richard_Mills+Annual_Profits
    if content =~ /\$[\-]?[0-9\.]+ B/
      currency = content[0]
      content.gsub!(' B', '')
      number = content[1..-1]
      big_number = BigDecimal.new(number) * 1_000_000_000
      mv.content = big_number.to_s
      puts "saving #{mv.name} as #{mv.content}".green
      mv.save!
      unit_card = Card.fetch "#{metric_name}+unit", new: {}
      if unit_card.new? || unit_card.content.empty?
        unit_card.content = currency
        puts "saving #{unit_card.name} as #{currency}".green
        unit_card.save!
      elsif unit_card.content != currency
        puts "non matched currency #{unit_card.content} to currency".red
      end
    else
      puts "#{mv.name}'s value is not handled: #{content}".red
    end
  end
end

Card::Auth.current_id = Card.fetch_id 'Richard Mills'
Card::Auth.as_bot do
  target_metrics = [
    Card['Richard_Mills+Employees'],
    Card['Ranking_Digital_Rights+Total_Score'],
    Card['CDP+Scope_1_Emissions'],
    Card['Newsweek+Newsweek_Green_Score'],
    Card['Richard_Mills+Annual_Profits'],
    Card['PERI_at_University_of_Massachusetts_Amherst+Toxic_Score']
  ]
  target_metrics.each do |metric|
    metric_value_type = Card["#{metric.name}+metric value type"].item_names[0]
    case metric_value_type
    when 'Number'
      standardize_numeric_metric_values metric.name
    when 'Monetory'
      standardize_currency_metric_values metric.name
    end
  end
end
