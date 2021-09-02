include_set Abstract::Table
include_set Abstract::PointerCachedCount
include_set Abstract::DatasetScope

def hereditary_field?
  false
end

def item_cards_for_validation
  item_cards.sort_by(&:name).reverse
end

format :html do
  def input_type
    :multiselect
  end

  view :core do
    wrap_with :div, class: "progress-bar-table" do
      year_progress_table
    end
  end

  def year_progress_table
    wikirate_table :year,
                   card.all_item_dataset_cards,
                   [:fancy_year, :research_progress_bar],
                   header: ["Year", "Answers Researched"],
                   td: { classes: ["year-answer", "default-progress-box"] }
  end
end
