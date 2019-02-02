# for this to work, you have to define at a minimum:
#
# 1. #num_possible returning the total number of answers/records in the problem space
# 2. #where_answer returning query args for an answer query

CSS_CLASS = { not_researched: "progress-not-researched" }.freeze
LINK_VALUE = { not_researched: "none" }.freeze
HOVER_TEXT = { known: "Known",
               unknown: "Unknown",
               not_researched: "Not Researched" }.freeze

# most common pattern is <TYPE>+<Project> (ltype_rtype)
# overridden elsewhere
def project_card
  @project_card ||= right
end

# has an answer
def num_researched
  @num_researched ||= smart_count { count_researched }
end

# researched and value is not "Unknown"
def num_known
  @num_known ||= smart_count { count_known }
end

# answer's value is "Unknown"
def num_unknown
  @num_unknown ||= num_researched - num_known
end

# no answer
def num_not_researched
  @num_not_researched ||= num_possible - num_researched
end

def percent_researched
  @percent_researched ||= percent_of_possible num_researched
end

def percent_not_researched
  @percent_not_researched ||= percent_of_possible num_not_researched
end

def percent_known
  @percent_known ||= percent_of_possible num_known
end

def percent_unknown
  @percent_unknown ||= percent_of_possible num_unknown
end

def percent_of_possible value
  percent value, num_possible
end

def count_researched
  researched_relation.count
end

def count_known
  researched_relation.where.not(value: "Unknown").count
end

def answers
  Answer.where where_answer
end

def record_ids
  Answer.select(:record_id).distinct.where where_answer
end

def researched_relation
  project_card.years ? answers : record_ids
end

def where_year
  where = yield
  where[:year] = project_card.years if project_card.years
  where
end

def smart_count
  return 0 unless num_possible.positive?
  yield
end

format :html do
  def research_progress_bar link_method=nil
    return "" unless card.num_possible.positive?
    sections = research_progress_bar_sections link_method
    progress_bar(*sections)
  end

  def research_progress_bar_sections link_method
    [:known, :unknown, :not_researched].map do |value|
      research_progress_bar_section value, link_method
    end.compact
  end

  def research_progress_bar_section value, link_method
    num = card.send "num_#{value}"
    return if num.zero?
    {
      value: card.send("percent_#{value}"),
      body: progress_section_body(value, link_method, num),
      class: progress_section_css_class(value),
      title: "#{HOVER_TEXT[value]} #{units}"
    }
  end

  def progress_section_css_class value
    CSS_CLASS[value] || "progress-#{value}"
  end

  def link_value value
    LINK_VALUE[value] || value
  end

  def progress_section_body value, link_method, num
    if link_method
      send(link_method, link_value(value)) { num }
    else
      num
    end
  end
end
