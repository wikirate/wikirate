# TODO: Many of these methods should be "answer", not "value"

# @example
# create_values do
#   Siemens 2015 => 4, 2014 => 3
#   Apple   2105 => 7
# end
def create_values random_source=false, &block
  Card::Metric::ValueCreator.new(self, random_source, &block).add_values
end

# @param [Hash] args
# @option args [String] :company
# @option args [String] :year
# @option args [String] :value
# @option args [String] :source source url
def create_value args
  unless (valid_args = create_value_args args)
    raise "invalid value args: #{args}"
  end
  Card.create! valid_args
end

def add_value_source_args args, source
  source_hash = case source
                when Hash   then source
                when String then { content: "[[#{source}]]" }
                when Card   then { content: "[[#{source.name}]]" }
                end
  return unless source_hash
  source_hash[:type_id] ||= Card::PointerID
  args["+source"] = source_hash
end

def extract_metric_value_name args, error_msg
  args[:name] || begin
    missing = [:company, :year, :value].reject { |v| args[v] }
    if missing.empty?
      value_name_from_args args
    else
      error_msg.push("missing field(s) #{missing.join(',')}")
      nil
    end
  end
end

def check_for_value_conflict args, error_msg
  return unless (value_name = extract_metric_value_name(args, error_msg))
  value_card = Card[value_name.to_name.field(:value)]
  return unless value_card&.new_value?(args[:value])
  link = format.link_to_card value_card.metric_card, "value"
  error_msg << "#{link} '#{value_card.content}' exists"
end

def valid_value_args? args
  error_msg = []
  check_for_value_conflict args, error_msg unless args.delete(:ok_to_exist)
  error_msg << "missing source" if metric_type_codename == :researched && !args[:source]
  error_msg.each do |msg|
    errors.add "metric value", msg
  end
  error_msg.empty?
end

def value_name_from_args args
  [name, args[:company], args[:year], args[:related_company]].compact.join "+"
end

def answer_type_id related_company
  related_company ? Card::RelationshipAnswerID : Card::MetricAnswerID
end

def add_answer_discussion_args hash, comment
  hash["+discussion"] = { comment: comment } if comment.present?
end

def create_value_args args
  return unless valid_value_args? args
  create_args = { name: value_name_from_args(args),
                  type_id: answer_type_id(args[:related_company]),
                  "+value" => { content: args[:value],
                                type_code: value_cardtype_code } }
  add_answer_discussion_args create_args, args[:comment]
  add_value_source_args create_args, args[:source]
  create_args
end
