    card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"

card_accessor :metric_type,
              :type=>:pointer, :default=>"[[Researched]]"



def metric_type
  metric_type_card.item_names.first
end

def metric_type_codename
  Card[metric_type].codename
end

    # def value company, year
#   (value_card = Card["#{name}+#{company}+#{year}+#{value}"]) &&
#     value_card.content
# end

def create_value args
  missing = [:company, :year, :value].reject { |v| args[v] }
  if missing.present?
    errors.add 'metric value', "missing #{missing.to_sentence}"
    return
  end
  create_args = {
    name: "#{name}+#{args[:company]}+#{args[:year]}",
    type_id: Card::MetricValueID,
    '+value' => args[:value]
  }
  if metric_type_codename == :reseached
    if !args[:source]
      errors.add 'metric value', "missing source"
      return
    end
    create_args[:source] = args[:source]
  end
  Card.create! create_args
end

def companies_with_years_and_values
  Card.search(right: 'value', left: {
    left: { left: card.name },
    right: { type: 'year' }
    }).map do |card|
    [card.cardname.left_name.left_name.right, card.cardname.left_name.right, card.content]
  end
end

format :html do
  view :legend do |args|
    if (unit = Card.fetch("#{card.name}+unit"))
      unit.raw_content
    elsif (range = Card.fetch("#{card.name}+range"))
      "/#{range.raw_content}"
    else
      ''
    end
  end

  def view_caching?
    true
  end
end

format :json do
  view :content do
    companies_with_years_and_values.to_json
  end
end
