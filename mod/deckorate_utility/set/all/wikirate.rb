require "net/https"
require "uri"

# for now, no notifications on acts using API key
def silent_change?
  Card::Auth.api_act? || super
end

def as_wikirate_team?
  Card::Auth.as_id == Card::WikirateTeamID
end

def as_moderator?
  Card::Auth.always_ok? || as_wikirate_team?
end

format do
  view :license do
    "Creative Commons Attribution-ShareAlike 4.0 International License"
  end

  def rate_subject
    @wikirate_subject ||= Card.fetch_name(:wikirate_company)
  end

  def rate_subjects
    @wikirate_subjects ||= rate_subject.pluralize
  end
end

format :csv do
  def metadata_hash
    { url: request_url, license: render_license, time: Time.now.to_s }
  end

  def with_metadata
    # h = metadata_hash
    # metadata_rows = [h.keys, h.values, []].map { |line| CSV.generate_line line }.join
    # metadata_rows = h.to_a.map do |line|
    #   line[0] = "# #{line[0]}"
    #   line
    # end
    metadata_rows = (metadata_hash.values << "").map { |v| ["# #{v}".strip] }
    metadata_rows + yield
  end
end

format :html do
  view :name_formgroup do
    # force showing help text
    voo.help ||= true
    super()
  end

  # TODO: refactor away
  view :menued do
    render_titled hide: [:title, :toggle], show: :menu
  end

  view :type_link, template: :haml do
    @type_card = card.type_card
  end

  def default_nest_view
    :content
  end

  def type_link_label
    @type_card.name
  end

  def type_link_icon
    mapped_icon_tag @type_card.codename
  end
end
