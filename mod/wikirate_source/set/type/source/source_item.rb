format :html do
  def year
    return card.fetch(trait: :year).content if card.fetch(trait: :year)
    ""
  end

  def wrap_with_info content
    html_class = "source-info-container with-vote-button"
    wrap do
      content_tag(:div, content.html_safe, class: html_class)
    end
  end

  def add_toggle content
    wrap_with :div, class: "source-details-toggle",
                    data: { source_for: card.name, year: year } do
      content.html_safe
    end
  end

  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(core_edit: true)
  end

  def creator args
    "added #{_render_created_at(args)} ago by " \
    "#{nest Card.fetch(card.cardname.field('*creator')),
            view: :core,
            item: :link}"
  end

  def flat_list items
    content_tag :ul, class: "list-inline" do
      items.map { |item| concat(content_tag(:li, item)) }
    end
  end

  def website_text
    nest(Card.fetch(card.cardname.field("website"),
                    new: {}), view: :content, item: :name)
  end

  def title_text
    nest(Card.fetch(card.cardname.field("title"), new: {}), view: :needed)
  end

  def source_item_footer
    items = [
      _render_note_count.html_safe,
      _render_metric_count.html_safe,
      _render_original_with_icon
    ]
    items.unshift(_render_year_with_icon) unless year.nil? || year == ""
    items
  end

  def icon
    # default as link
    "globe"
  end

  view :source_content do |args|
    content = wrap_with :div, class: "source-content" do
      [
        _render_source_link(args),
        _render_creator_credit
      ]
    end
    _render_icon + content
  end

  view :source_list_item do |args|
    wrap_with :div, class: "source-item" do
      [
        _render_vote,
        _render_source_content(args),
        _render_extras
      ]
    end
  end

  view :extras do
    content = flat_list(source_item_footer)
    content_tag(:div, content.html_safe, class: "source-extra")
  end

  view :original_with_icon do
    icon = content_tag(:i, " ", class: "fa fa-external-link-square")
    icon + _render_original_link
  end

  view :vote do |args|
    vote_item = subformat(Card["#{card.name}+*vote count"]).render_content args
    content_tag(:div, vote_item, class: "source-vote")
  end

  view :icon do
    icon = content_tag(:i, " ", class: "fa fa-globe")
    content_tag(:div, icon, class: "source-icon")
  end

  view :creator_credit do |args|
    content_tag(:div, creator(args).html_safe, class: "last-edit")
  end

  view :website_link do |_args|
    card_link(
      card,
      text: website_text,
      class: "source-preview-link",
      target: "_blank"
    )
  end

  view :title_link do |_args|
    card_link(
      card,
      text: title_text,
      class: "source-preview-link preview-page-link",
      target: "_blank"
    )
  end

  view :source_link do |args|
    if args[:source_title] == :text
      website = website_text
      title = title_text
    else
      website = _render_website_link
      title = _render_title_link
    end
    wrap_with :div, class: "source-link" do
      [
        content_tag(:span, website, class: "source-website"),
        content_tag(:i, "", class: "fa fa-long-arrow-right"),
        content_tag(:span, title, class: "source-title")
      ]
    end
  end

  view :year_helper do
    return "" if year.nil? || year == ""
    content_tag(:small, "year:" + year[/\d+/], class: "source-year")
    # _render_original_link << year_helper.html_safe
  end

  view :year_with_icon do
    return "" if year.nil? || year == ""
    icon = content_tag(:i, "", class: "fa fa-calendar")
    content_tag(:span, icon + year[/\d+/])
  end

  view :direct_link do
    if card.source_type_codename == :wikirate_link
      link = card.fetch(trait: :wikirate_link).content
      <<-HTML
        <a class="view-original-url" href="#{link}" target="_blank">
          <i class="fa fa-external-link-square cursor"></i>
           Original
        </a>
      HTML
    else
      ""
    end
  end

  view :with_cite_button do |args|
    cite_button =
      content_tag(:div, "Cite!", class: "btn btn-highlight _cite_button c-btn")
    content =
      _render_source_list_item(args) +
      content_tag(:div, cite_button, class: "pull-right")
    wrap_with_info content
  end

  view :source_and_preview do |args|
    wrap_with :div, class: "source-details",
                    data: { source_for: card.name, year: year } do
      url_card = card.fetch(trait: :wikirate_link)
      url = url_card ? url_card.item_names.first : nil
      args[:url] = url
      render_with_cite_button +
        render_iframe_view(args.merge(url: url)).html_safe +
        render_hidden_information(args.merge(url: url)).html_safe
    end
  end

  view :relevant do |args|
    args[:source_title] = :text
    add_toggle render_with_cite_button(args).html_safe
  end

  view :cited do |args|
    parent = Card.fetch(Env.params["id"]).cardname.right
    # check parent structure name has the word header
    # (i.e check if not metric value page)
    if !parent.nil? && parent.include?("header")
      return wrap_with_info _render_source_list_item(args)
    else
      args[:source_title] = :text
      source = wrap_with_info _render_source_list_item(args)
      add_toggle(source)
    end
  end

  view :metric_import_link do |_args|
    ""
  end

  view :original_icon_link do |args|
    icon = content_tag(:i, "", class: "fa fa-#{icon}")
    _render_original_link args.merge(title: icon)
  end

  view :content do |args|
    add_name_context
    super args
  end

  view :missing do |args|
    _view_link args
  end

  view :titled, tags: :comment do |args|
    render_titled_with_voting args
  end

  view :open do |args|
    super args.merge(custom_source_header: true)
  end

  view :header do |args|
    if args.delete(:custom_source_header)
      render_header_with_voting
    else
      super(args)
    end
  end

  # TODO: reuse the following in source_preview.rb
  view :metric_count do
    <<-HTML

    <span id="metric-count-number " class="count-number">
    <i class="fa fa-bar-chart"></i>#{metric_count}</span>
    <span>#{Card[MetricID].name.pluralize}</span>
    HTML
  end

  view :note_count do
    note_count = nest(Card.fetch("#{card.name}+Note Count"), view: :core)
    <<-HTML

    <!-- <a href='/#{card.name}+source note list' class="show-link-in-popup"> -->
      <span class="note-count">
      <i class="fa fa-quote-left"></i>#{note_count}</span>
      <span class="note-count">Notes</span>
    <!-- </a> -->
    HTML
  end
end
