require "curb"
card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :contribution_count, type: :number, default: "0"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :source_type, type: :pointer, default: "[[Link]]"

def indirect_contributor_search_args
  [{ right_id: VoteCountID, left: name }]
end

require "link_thumbnailer"

# has to happen before the contributions update (the new_contributions event)
# so we have to use the finalize stage
event :vote_on_create_source, :integrate,
      on: :create,
      when: proc { Card::Auth.current_id != Card::WagnBotID } do
  Auth.as_bot do
    vc = vote_count_card
    vc.supercard = self
    vc.vote_up
    vc.save!
  end
end

event :check_source, :validate, on: :create do
  source_cards = [subfield(:wikirate_link),
                  subfield(:file),
                  subfield(:text)].compact
  if source_cards.length > 1
    errors.add :source, "Only one type of content is allowed"
  elsif source_cards.empty?
    errors.add :source, "Source content required"
  end
end

def source_type_codename
  source_type_card.item_cards[0].codename.to_sym
end

def analysis_names
  return [] unless (topics = fetch(trait: :wikirate_topic)) &&
                   (companies = fetch(trait: :wikirate_company))
  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company}+#{topic}"
    end
  end.flatten
end

def analysis_cards
  analysis_names.map { |aname| Card.fetch aname }
end

# event :source_present, :validate, on: :create,
#       when: { Env.params[:preview] } do
#   if ...
#     errors.add :source, ''
#   end
# end

format :html do
  view :new do
    preview? ? _optional_render_preview : super()
  end

  def preview?
    return false if @previewed
    @previewed = true
    Env.params[:preview]
  end

  view :preview do
    voo.structure = "metric value source form"
    card_form :create, "main-success" => "REDIRECT",
                       "data-form-for" => "new_metric_value",
                       class: "card-slot new-view TYPE-source" do
      output [
        preview_hidden,
        new_view_name,
        new_view_type,
        _optional_render_content_formgroup,
        _optional_render_preview_buttons
      ]
    end
  end

  def new_view_hidden
    hidden_tags success: {
      id: "_self", soft_redirect: true, view: :source_and_preview
    }
  end

  view :preview_buttons do
    button_formgroup do
      wrap_with :button, "Add and preview", class: "btn btn-primary pull-right",
                                            data: { disable_with: "Adding" }
    end
  end

  def preview_hidden args={}
    # FIXME: company arg getting lost?
    hidden_field_tag "card[subcards][+company][content]", args[:company]
  end
end
