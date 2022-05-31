# cache # of companies in this group
include_set Abstract::ListCachedCount
include_set Abstract::IdPointer

delegate :specification_card, to: :left
delegate :explicit?, :implicit?, to: :specification_card

def history?
  explicit?
end

def update_content_from_spec
  self.content = specification_card.implicit_item_names if implicit?
end

def bookmark_type
  :wikirate_company
end

format :html do
  view :filtered_content, cache: :never do
    if card.explicit?
      wrap { [%{<div class="py-3">#{render_menu}</div>}, nest_search_card] }
    else
      nest_search_card
    end
  end

  def nest_search_card
    field_nest :company_search, view: :filtered_content, items: { view: :bar }
  end

  def input_type
    card.count > 500 ? :list : :filtered_list
  end

  def default_item_view
    :thumbnail_no_link
  end

  def filter_card
    :wikirate_company.card
  end
end
