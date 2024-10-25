include_set Abstract::FluidLayout
include_set Abstract::FancyCounts
include_set Abstract::AboutPages
include_set Abstract::CompanySlider

format :html do
  view :page, template: :haml, cache: :deep

  def edit_fields
    absolutize_edit_fields %i[main_community_heading community_action_heading] +
                           %i[wikirate_community blurb].card.item_names +
                           [:community_member_heading,
                            # %i[account featured],
                            %i[organizer featured],
                            :project_organizer_heading,
                            %i[wikirate_community quote],
                            :community_cta,
                            :contact_cta1,
                            :contact_cta2]
  end

  def count_categories
    %i[account designer research_group project]
  end

  def breadcrumb_title
    "Community"
  end

  def companies_for_slider
    %i[organizer featured].card&.item_cards || []
  end

  def company_detail organizer
    count = organizer.projects_organized_card.count
    "#{count} #{:project.cardname.pluralize count}"
  end
end
