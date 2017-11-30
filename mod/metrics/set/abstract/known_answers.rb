# for this to work, you have to define at a minimum:
#
# 1. #num_records returning the total number of records in the problem space
# 2. #where_answer returning query args for an answer query
# 3. #worth_counting? returning false if there are obviously no answers yet.

CSS_CLASS = { not_researched: "progress-not-researched" }.freeze
LINK_VALUE = { not_researched: "none" }.freeze

# currently counts as researched if metric card exists at all
def num_researched
  @num_researched ||= smart_count { count_researched }
end

# researched and has a value that is not "Unknown"
def num_known
  @num_known ||= smart_count { count_known }
end

def num_unknown
  @num_unknown ||= num_researched - num_known
end

def num_not_researched
  @num_not_researched ||= num_records - num_researched
end

def percent_researched
  @percent_researched ||= percent_of_records num_researched
end

def percent_not_researched
  @percent_not_researched ||= percent_of_records num_not_researched
end

def percent_known
  @percent_known ||= percent_of_records num_known
end

def percent_unknown
  @percent_unknown ||= percent_of_records num_unknown
end

def percent_of_records value
  percent value, num_records
end

def count_researched
  researched_relation.count
end

def count_known
  researched_relation.where.not(value: "Unknown").count
end

def researched_relation
  Answer.select(:record_id).distinct.where where_answer
end

def smart_count
  return 0 unless worth_counting?
  yield
end

format :html do
  def research_progress_bar link_method=nil
    return "" unless card.worth_counting?
    sections = [:known, :unknown, :not_researched].map do |value|
      research_progress_bar_section value, link_method
    end.compact
    progress_bar(*sections)
  end

  def research_progress_bar_section value, link_method
    percent = card.send "percent_#{value}"
    return if percent.to_i.zero?
    hash = { value: percent, class: progress_css_class(value) }
    link_progress_bar_section hash, value, link_method
    hash
  end

  def progress_css_class value
    CSS_CLASS[value] || "progress-#{value}"
  end

  def link_progress_bar_section hash, value, link_method
    return unless link_method
    hash[:body] = send link_method, LINK_VALUE[value] do
      card.send "num_#{value}"
    end
  end
end
