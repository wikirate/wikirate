# @param args [Hash]
# @option args [String] :company
# @option args [String] :year
# @option args [String] :value
# @option args [String] :source source url
def create_record args
  raise "invalid record args: #{args}" unless (valid_args = create_record_args args)
  Card.create! valid_args
end

def add_record_source_args args, source
  return unless source.present?
  source_hash = source.is_a?(Hash) ? source : { content: "[[#{Card::Name[source]}]]" }
  source_hash[:type_id] ||= PointerID
  args["+source"] = source_hash
end

def extract_record_name args, error_msg
  args[:name] || begin
    missing = [:company, :year, :value].reject { |v| args[v] }
    if missing.empty?
      record_name_from_args args
    else
      error_msg.push("missing field(s) #{missing.join(',')}")
      nil
    end
  end
end

def check_for_record_conflict args, error_msg
  return unless (record_name = extract_record_name(args, error_msg))
  value_card = Card[record_name.to_name.field(:value)]
  return unless value_card&.new_value?(args[:value])
  link = format.link_to_card value_card.metric_card, "value"
  error_msg << "#{link} '#{value_card.content}' exists"
end

def valid_record_args? args
  error_msg = []
  check_for_record_conflict args, error_msg unless args.delete(:ok_to_exist)
  error_msg << "missing source" if metric_type_codename == :researched && !args[:source]
  error_msg.each do |msg|
    errors.add "record", msg
  end
  error_msg.empty?
end

def record_name_from_args args
  parts = [name, args[:company], args[:year].to_s]
  parts << args[:related_company] if args[:related_company]
  Card::Name[*parts]
end

def record_type_id related_company
  related_company ? RelationshipID : RecordID
end

def add_record_discussion_args hash, comment
  hash["+discussion"] = { comment: comment } if comment.present?
end

def add_unpublished_args hash, val
  hash["+unpublished"] = { content: val } if val.present?
end

def create_record_args args
  return unless valid_record_args? args
  create_args = { name: record_name_from_args(args),
                  type_id: record_type_id(args[:related_company]),
                  "+value" => args[:value] }
  add_record_discussion_args create_args, args[:comment]
  add_record_source_args create_args, args[:source]
  add_unpublished_args create_args, args[:unpublished]
  create_args.merge args.slice(:trigger, :trigger_in_action)
end
