# for this to work, you have to define #num_records, #where_answer, and
# #smart_count?

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


view :research_progress_bar, cache: :never do
  progress_bar(
    { value: card.percent_known, class: "progress-known" },
    { value: card.percent_unknown, class: "progress-unknown" },
    value: card.percent_not_researched, class: "progress-not-researched"
  )
end

view :absolute_research_progress_bar, cache: :never do
  progress_bar(
    { value: card.percent_known, label: card.num_known,
      class: "progress-known" },
    { value: card.percent_unknown, label: card.num_unknown,
      class: "progress-unknown" },
    value: card.percent_not_researched, label: card.num_not_researched,
    class: "progress-not-researched"
  )
end
