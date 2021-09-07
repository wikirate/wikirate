include_set Abstract::Thumbnail
include_set Abstract::TwoColumnLayout
include_set Abstract::Bookmarkable

card_accessor :dataset
card_accessor :unpublished
card_reader :organizer

def organizer?
  as_moderator? || organizer_card.item_ids.include?(Auth.as_id)
end

format :html do
  before :content_formgroups do
    voo.edit_structure = %i[image organizer description]
  end

  view :data do
    wrap_with :div, class: "project-details" do
      [
        labeled_field(:organizer, :thumbnail),
        default_unpublished,
        field_nest(:description, view: :titled),
        field_nest(:conversation, view: :titled)
      ]
    end
  end

  def default_unpublished
    return unless card.organizer?

    labeled_field :unpublished, nil, title: "Default unpublished"
  end
end
