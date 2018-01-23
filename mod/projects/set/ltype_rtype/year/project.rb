include_set Abstract::KnownAnswers

def year_card
  @year_card ||= left
end

def where_answer
  where = project_card.where_record
  where[:year] = year
  where
end

def year
  year_card.name
end

def num_possible
  @num_possible ||= project_card.num_possible_records
end

format :html do
  view :fancy_year do
    "<BLINK>#{card.year}</BLINK>"
  end

  view :research_progress_bar, cache: :never, tags: :unknown_ok do
    research_progress_bar
  end
end
