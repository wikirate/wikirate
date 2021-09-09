include_set Abstract::Thumbnail
include_set Abstract::TwoColumnLayout
include_set Abstract::Bookmarkable

card_accessor :unpublished
card_accessor :wikirate_status
card_accessor :organizer

def organizer?
  as_moderator? || organizer_card.item_ids.include?(Auth.as_id)
end

def dataset_pointer
  fetch :dataset
end

def dataset_card
  @dataset_card ||= dataset_pointer&.first_card
end

def dataset_name
  dataset_pointer.first_name
end

delegate :metrics, :companies, :years,
         :metric_list, :company_list, :year_list,
         :metric_ids, :company_ids, :year_ids,
         to: :dataset_card

# used in filtering answers on company and dataset pages
# @param values [Symbol] researched, known, not_researched
# (need better term for this param)
def filter_path_args values
  filter = { project: name, status: values  }
  # show latest dataset year.  could consider updating answer tables
  # to handle latest value among a group of years, but that's not yet
  # an option
  filter[:year] = years.first if years && years.one?
  { filter: filter }
end

format :html do
  def image_card
    @image_card ||= card.dataset_card&.fetch :image, new: {}
  end

  before :content_formgroups do
    voo.edit_structure = %i[wikirate_status dataset organizer description]
  end

  view :data do
    wrap_with :div, class: "project-details" do
      [
        nest(card.dataset_card, view: :overall_progress_box),
        labeled_field(:dataset, :link),
        labeled_field(:wikirate_status, :name),
        labeled_field(:organizer, :thumbnail),
        default_unpublished,
        field_nest(:description, view: :titled),
        field_nest(:conversation, view: :titled)
      ]
    end
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [render_type_link, render_tabs]
    end
  end

  def default_unpublished
    labeled_field :unpublished, nil, title: "Default unpublished" if card.organizer?
  end

  def tab_list
    [:wikirate_company, :metric]
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :filtered_content
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end
end
