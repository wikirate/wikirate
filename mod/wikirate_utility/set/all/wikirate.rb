require "net/https"
require "uri"

format do
  view :cgi_escape_name do
    CGI.escape card.name
  end

  def rate_subject
    @wikirate_subject ||= Card.fetch_name(:wikirate_company)
  end

  def rate_subjects
    @wikirate_subjects ||= rate_subject.pluralize
  end
end

format :html do
  view :titled_row do
    [
      { content: _render_title, class: "title" },
      { content: _render_core, class: "value" }
    ]
  end

  view :name_formgroup do
    # force showing help text
    voo.help ||= true
    super()
  end

  view :panel_primary, template: :haml, cache: :never do
    root.primary_panels << card.tag
  end

  view :panel_toc, template: :haml, cache: :never

  # deprecated
  # still used in some card
  # e.g. source+*self+*structure
  view :listing do
    _render_bar
  end

  def primary_panels
    @primary_panels ||= []
  end

  def main_name
    left_name = card.name.left_name
    left_name = left_name.left unless card.key.include?("limited_metric")
    @main_name ||= left_name
  end

  # def main_type_id
  #   @main_type_id ||= Card.fetch(main_name).type_id
  # end

  # def searched_type_id
  #   @searched_type_id ||= card.name.left_name.right.card_id
  # end

  def button_classes
    "btn btn-sm btn-outline-secondary"
  end
end
