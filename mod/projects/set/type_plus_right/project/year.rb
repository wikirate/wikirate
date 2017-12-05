include_set Abstract::Table

def project_name
  name.left
end

def year_project_card year_name
  Card.fetch year_name, project_name, new: {}
end

def valid_year_cards
  @valid_year_cards ||=
    item_cards.sort_by(&:name).reverse.select do |year_card|
      year_card.type_id == YearID
    end
end

def all_year_project_cards
  valid_year_cards.map do |year_card|
    year_project_card year_card.name
  end
end

format :html do
  def editor
    :multiselect
  end

  view :core do
    wrap_with :div, class: "progress-bar-table" do
      year_progress_table
    end
  end

  def year_progress_table
    wikirate_table :year,
                   card.all_year_project_cards,
                   [:fancy_year, :research_progress_bar],
                   header: ["Year", "Answers Researched"],
                   td: { classes: ["year-answer","overall-progress-box"] }
  end
end
