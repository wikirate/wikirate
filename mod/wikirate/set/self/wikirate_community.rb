include_set Abstract::FluidLayout
include_set Abstract::FancyCounts
include_set Abstract::AboutPages

format :html do
  def edit_fields
    absolutize_edit_fields %i[main_community_heading community_action_heading] +
                           %i[wikirate_community blurb].card.item_names +
                           [:community_member_heading, [:account, :featured]]
  end

  def count_categories
    %i[designer research_group project]
  end

  def breadcrumb_title
    "Our Community"
  end

  view :page, template: :haml
end
