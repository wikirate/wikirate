# WikiRating metrics use +:metric_variables cards for managing the filtered list
# interface.

# when metrics are selected, the thumbnails are copied into a templated row in the
# formula table via JavaScript

format :html do
  view :edit_in_wikirating, unknown: true do
    variable_editor { output [hidden_thumbnails, add_wikirating_variable_button] }
  end

  def hidden_thumbnails
    wrap_with :div, class: "weight-variable-list hidden" do
      card.item_cards.map do |metric|
        nest metric, view: :thumbnail_no_link
      end
    end
  end

  def add_wikirating_variable_button
    add_variable_button "_add-wikirating-variable",
                        slot_selector(:edit_in_wikirating),
                        metric_type: %i[score wiki_rating].map { |mt| Card::Name[mt] }
  end
end
