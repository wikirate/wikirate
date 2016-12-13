# for this to work, you have to define #records, #researched_wql, and
# #worth_counting

def unknown
  @unknown ||= researched - known
end

def not_researched
  @not_researched ||= records - researched
end

def percent_researched
  @percent_researched ||= percent_of_records researched
end

def percent_not_researched
  @percent_not_researched ||= percent_of_records not_researched
end

def percent_known
  @percent_known ||= percent_of_records known
end

def percent_unknown
  @percent_unknown ||= percent_of_records unknown
end

def percent_of_records value
  percent value, records
end

# currently counts as researched if metric card exists at all
def researched
  @researched ||= worth_counting { search_for_researched }
end

# researched and has a value that is not "Unknown"
def known
  @known ||= worth_counting { search_for_known }
end

def search_for_known
  Card.search researched_wql.merge(
    right_plus: [{ type_id: YearID }, { ne: "Unknown" }]
  )
end

def search_for_researched
  Card.search researched_wql
end

