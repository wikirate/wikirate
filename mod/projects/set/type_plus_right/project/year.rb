include_set Abstract::Table
include_set Abstract::ProjectScope

def item_cards_for_validation
  item_cards.sort_by(&:name).reverse
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
                   card.all_item_project_cards,
                   [:fancy_year, :research_progress_bar],
                   header: ["Year", "Answers Researched"],
                   td: { classes: ["year-answer", "default-progress-box"] }
  end
end
