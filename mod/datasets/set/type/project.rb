include_set Abstract::Thumbnail
include_set Abstract::TwoColumnLayout
include_set Abstract::Bookmarkable

card_accessor :unpublished
card_reader :organizer

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

format :html do
  before :content_formgroups do
    voo.edit_structure = %i[image dataset organizer description]
  end

  view :data do
    wrap_with :div, class: "project-details" do
      [
        nest(card.dataset_card, view: :overall_progress_box),
        labeled_field(:dataset, :link),
        labeled_field(:organizer, :thumbnail),
        default_unpublished,
        field_nest(:description, view: :titled),
        field_nest(:conversation, view: :titled)
      ]
    end
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      render_tabs
    end
  end

  def default_unpublished
    labeled_field :unpublished, nil, title: "Default unpublished" if card.organizer?
  end

  def tab_list
    [:wikirate_company] #, :metric, (:year if card.years), :data_subset].compact
  end

  view :wikirate_company_tab do
    tab_nest :wikirate_company
  end
end
