include_set Abstract::BsBadge
include_set Abstract::Table
include_set Abstract::BrowseFilterForm
include_set Abstract::LookupSearch

def item_type
  "Answer" # :metric_answer.cardname
end

def filter_class
  AnswerQuery
end

format do
  def filter_hash_from_params
    super.tap do |h|
      normalize_filter_hash h if h
    end
  end

  def filter_keys
    standard_filter_keys + special_filter_keys
  end

  def special_filter_keys
    [].tap do |keys|
      keys << :published if Card::Auth.current.stewards_any?
    end
  end

  def card_content_limit
    nil
  end

  def default_limit
    Auth.signed_in? ? 5000 : 500
  end

  private

  def normalize_filter_hash hash
    %i[metric company].each do |type|
      handle_exact_name hash, type
      handle_project_filter hash
    end
  end

  # names prefixed with an equals sign are treated as "exact" names
  def handle_exact_name hash, type
    key = :"#{type}_name"
    name = hash[key]
    return unless name&.match(/^=/)

    hash.delete key
    hash[:"#{type}_id"] = name.card_id
  end

  def handle_project_filter hash
    return unless (dataset = hash.delete :project)

    hash[:dataset] ||= dataset
  end
end

format :csv do
  view :core do
    Answer.csv_title + lookup_relation.map(&:csv_line).join
  end
end
