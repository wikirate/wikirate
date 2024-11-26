include_set Abstract::KnownAnswers

def year_card
  @year_card ||= left
end

def where_answer
  where = dataset_card.where_record
  where[:year] = year
  where
end

def year
  year_card.name
end

def num_possible
  @num_possible ||= dataset_card.num_possible_answers
end

format :html do
  def units
    card.dataset_card.units
  end

  view :fancy_year do
    "<BLINK>#{card.year}</BLINK>"
  end

  view :research_progress_bar, cache: :never, unknown: true do
    research_progress_bar
  end
end
