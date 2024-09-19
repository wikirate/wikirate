include_set Abstract::Thumbnail
include_set Abstract::DeckorateTabbed
include_set Abstract::Bookmarkable

card_accessor :unpublished, type: :toggle, default_content: "No"
card_accessor :wikirate_status, type: :pointer
card_accessor :organizer, type: :list

require_field :dataset

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
  dataset_pointer&.first_name
end

delegate :metrics, :companies, :years, :metric_ids, :company_ids, :year_ids,
         :filter_path_args, to: :dataset_card

format :html do
  def image_card
    @image_card ||= card.dataset_card&.fetch(:image) || super
  end

  before :content_formgroups do
    voo.edit_structure = %i[wikirate_status dataset organizer description]
  end

  def default_unpublished
    labeled_field :unpublished, nil, title: "Default unpublished" if card.organizer?
  end

  def tab_list
    %i[details company metric]
  end

  view :company_tab do
    field_nest :company, view: :filtered_content
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :details_tab_left do
    [
      nest(card.dataset_card, view: :overall_progress_box),
      field_nest(:description, view: :titled),
      field_nest(:conversation, view: :titled)
    ]
  end

  view :details_tab_right do
    labeled_fields do
      [
        labeled_field(:dataset, :thumbnail),
        labeled_field(:organizer, :thumbnail),
        labeled_field(:wikirate_status, :name),
        default_unpublished
      ]
    end
  end
end
