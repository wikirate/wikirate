require "net/https"
require "uri"

format do
  view :raw_or_blank, perms: :none, closed: true do
    _render_raw || ""
  end

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
  NEW_BADGE = '<span class="badge badge-danger">New</span>'.freeze

  # def menu_icon
  #   fa_icon "pencil-square-o"
  # end

  def header_title_elements
    voo.hide :title_badge
    [super, _render_title_badge]
  end

  view :title_badge do
    wrap_with :span, title_badge_count, class: "badge"
  end

  def title_badge_count
    card.count
  end

  view :og_source, unknown: true do
    if card.real?
      card.format.render_source
    else
      Card["*Vertical_Logo"].format.render_source size: "large"
    end
  end

  view :meta_preview do
    content = _render_core
    truncated = Card::Content.smart_truncate content, 50
    ::ActionView::Base.full_sanitizer.sanitize truncated
  end

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

  view :wikirate_modal do
    card_name = Card::Env.params[:show_modal]
    if card_name.present?
      after_card = Card[card_name]
      if !after_card
        Rails.logger.info "Expect #{card_name} exist"
        "" # otherwise it will return true
      else
        "<div class='modal-window'>#{subformat(after_card).render_core} </div>"
      end
    else
      ""
    end
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

  def main_type_id
    @main_type_id ||= Card.fetch(main_name).type_id
  end

  def searched_type_id
    @searched_type_id ||= Card.fetch_id card.name.left_name.right
  end

  def button_classes
    "btn btn-sm btn-outline-secondary"
  end
end
