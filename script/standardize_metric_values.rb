require File.expand_path('../../config/environment', __FILE__)

def number? str
  true if Float(str)
rescue
  false
end

def potential_numeric_metrics_wql
  { type_id: Card::MetricID,
    right_plus: [
      { type_id: Card::WikirateCompanyID },
      right_plus: [
        { type: 'year' },
        right_plus: [
          'value', { content: ['match', '[[:digit:]]+'] }
        ]
      ]
    ]
  }
end

def find_potential_numeric_metrics
  metrics = Card.search potential_numeric_metrics_wql
  potential_result = []
  metrics.each do |m|
    value_type = Card.fetch("#{m.name}+value type", new: {})
    if value_type.new? || value_type.content.include?('[[Number]]')
      potential_result.push(m)
    end
  end
  potential_result
end

def update_metric_value card, mv_type, content, type='[[Number]]'
  puts "Updating #{card.name} from #{card.content} to #{content}".green
  card.content = content
  card.save!
  update_metric_value_type mv_type, type
end

def update_metric_value_type mv_type, type
  return if mv_type.content.include?(type)
  mv_type.content = type
  puts "Updating #{mv_type.name} as [[Number]]".green
  mv_type.save!
end

def convert_to_big_number number, unit
  multiplier =
    case unit
    when 'B'
      1_000_000_000
    when 'M'
      1_000_000
    when 'K'
      1_000
    end
  BigDecimal.new(number) * multiplier
end

def metric_values metric_name
  Card.search left: {
    type_id: Card::MetricValueID,
    left: { left: metric_name }
  }, right: 'value'
end

def convert_potential_metrics potential_result
  potential_result.each do |m|
    puts "======== Normalizing #{m.name} ========".blue
    metric_values = metric_values m.name
    if unknown_inside? metric_values
      puts "Skip the #{m.name} because unknown inside".red
      Card.create! name: "#{m.name}+pending_normalize", type_id: Card::PhraseID,
                   content: 'true'
    else
      metric_values.each do |mv|
        value_type = Card.fetch("#{m.name}+value type", new: {})
        normalize_content mv, value_type
      end
    end
    puts "======== Finished normalizing #{m.name} ========".blue
  end
end

def unknown_inside? metric_values
  metric_values.each do |mv|
    content = mv.content.delete(',%')
    return true unless number?(content) || content =~ /\$[\-]?[0-9\.]+ [BMK]/
  end
  false
end

def normalize_content mv, value_type
  content = mv.content.delete(',%')
  if number?(content)
    update_metric_value mv, value_type, content if mv.content != content
    update_metric_value_type value_type, '[[Number]]'
  elsif content =~ /\$[\-]?[0-9\.]+ [BMK]/
    content.gsub!(/ [BMK]/, '')
    big_number = convert_to_big_number content[1..-1], mv.content[-1]
    update_metric_value mv, value_type, big_number.to_s, '[[Monetary]]'
    update_unit mv.metric_card, '$'
  else
    puts "unknown format: #{content}\t#{mv.name}".red
  end
end

def update_unit metric, unit
  unit_card = Card.fetch "#{metric.name}+unit", new: {}
  return if unit_card.content.include?(unit)
  puts "Updating #{unit_card.name} from #{unit_card.content} to #{unit}".green
  unit_card.content = unit
  unit_card.save!
end

def update_ratio_metric_info
  mn = 'PayScale+CEO to Worker pay'
  mvt = Card.fetch "#{mn}+value_type", new: {}
  mvt.content = '[[Number]]'
  mvt.save!
  mu = Card.fetch "#{mn}+unit", new: {}
  mu.content = ':01'
  mu.save!
end

def handle_ratio_metric
  ratio_mv = Card.search left: { left: 'PayScale+CEO to Worker pay' },
                         type_id: Card::MetricValueID, append: 'value'
  ratio_mv.each do |mv|
    mv_content = mv.content.clone
    if mv.content.gsub!(':01', '')
      mv.content.gsub!(/^0+/, '')
      puts "Updating #{mv.name} from #{mv_content} to #{mv.content}".green
      mv.save!
    else
      puts "invalid ratio format of #{mv.name}\t#{mv.content}".red
    end
  end
end

def convert_monetary_metric_unit
  metric_with_unit = Card.search type_id: Card::MetricID,
                                 right_plus: ['unit', content: '$'],
                                 return: 'name'
  # update's its value type and the currency
  metric_with_unit.each do |metric|
    name = "#{metric}+value_type"
    metric_value_type = Card.fetch name, new: {}
    metric_value_type.content = '[[Monetary]]'
    metric_value_type.save!

    metric_currency = Card.fetch "#{metric}+Currency", new: {}
    metric_currency.content = '$'
    metric_currency.save!

    Card["#{metric}+unit"].delete!
  end
end

def rename_existing_metric_value_type
  exisiting_value_type = Card.search right: 'value type',
                                     left: { type_id: Card::MetricID }
  exisiting_value_type.each do |metric_value_type|
    existing_type = metric_value_type.item_names[0]
    if (new_type_name = new_type_name existing_type)
      metric_value_type.content = new_type_name
    else
      puts "unknown type: #{metric_value_type.name}\t"\
           "#{metric_value_type.item_names[0]}"
      next
    end
    puts "Updating #{existing_type} to #{metric_value_type.content}".green
    metric_value_type.save!
  end
end

def new_type_name content
  number = ['Real']
  category = %w(String Boolean)
  if number.include?(content)
    '[[Number]]'
  elsif category.include?(content)
    '[[Category]]'
  end
end

def rest_metric
  result = Card.search type_id: Card::MetricID,
                       right_plus: ['value type', { content: '[[Category]]' }]
  result += Card.search(type_id: Card::MetricID,
                        not: { right_plus: 'value type' })

  unknown_inside_metric = Card.search(type_id: Card::MetricID,
                                      right_plus: 'pending_normalize')
  result.delete_if { |item| unknown_inside_metric.include?(item) }
  result
end

def update_value_type_category metrics
  metrics.each do |m|
    name = "#{m.name}+value_type"
    metric_value_type = Card.fetch name, new: {}
    next unless metric_value_type.new?
    puts "Updating #{name} to [[Category]]".green
    metric_value_type.content = '[[Category]]'
    metric_value_type.save!
  end
end

def update_options metrics
  metrics.each do |m|
    metric_values = metric_values m.name
    option_card = Card.fetch "#{m.name}+value options", new: {}
    options = []
    metric_values.each do |mv|
      options.push("[[#{mv.content}]]\n")
    end
    options.uniq!
    option_card.content = options.join('')
    puts "Saving #{option_card.name} as #{option_card.content}".green
    option_card.save!
  end
end

# ======== end of functions =======

Card::Auth.as_bot
Card::Auth.current_id = Card.fetch_id 'Richard Mills'
Card::Mailer.perform_deliveries = false
rename_existing_metric_value_type
convert_monetary_metric_unit

update_ratio_metric_info
handle_ratio_metric

# find the number metric
# 1. get a sample metric value from metrics
# 2. if it can be a number, turn them to real number
# 3. check
# set the rest as catgeory and put the values as options

potential_results = find_potential_numeric_metrics
convert_potential_metrics potential_results

# turn the rest to categorical metric
# use the existing values for the options
rest_metrics = rest_metric

# # set the metric type as category
# # get the value for options
update_value_type_category rest_metrics
update_options rest_metrics
Card::Mailer.perform_deliveries = true
