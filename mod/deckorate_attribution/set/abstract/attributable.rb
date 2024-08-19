card_accessor :reference, type: :search_type

def attribution_authors
  [creator&.name]
end

def attribution_title
  name
end

def attribution_changes_link?
  true
end

def attribution_changes_text
  "Filter for changes"
end

def attribution_changes_path created_at
  { filter: { updated: created_at } }
end

format do
  delegate :attribution_title, :attribution_authors, to: :card

  view :att_wikirate do
    "Wikirate.org"
  end

  view :att_title do
    "'#{attribution_title}' <#{render_id_url}> by #{render_attribution_authorship}"
  end

  view :attribution_authorship do
    attribution_authors.to_sentence
  end

  view :att_license do
    "licensed under #{license_text} <#{license_url}>"
  end

  private

  def license_url
    "https://creativecommons.org/licenses/by/4.0"
  end

  def license_text
    "CC BY 4.0"
  end
end

format :html do
  def bar_menu_items
    super.insert 3, attribution_link(text: "Attribute")
  end

  def menu_items
    super.unshift attribution_link
  end

  def history_view
    :history_and_references
  end

  # Generates an attribution link with optional parameters.
  #
  # @param [String] text The text displayed on the link.
  # @param [String] title ("Attribution") The title of the linked content.
  #
  # @return [String] The HTML code for the attribution link.
  #
  # @example
  #   attribution_link(text: "Details", title: "View Attribution Details")
  def attribution_link text: "", title: "Attribution"
    # , button: false
    modal_link "#{icon_tag :attribution} #{text}",
               size: :large,
               rel: "nofollow",
               # class: ("btn btn-primary" if button),
               path: { mark: :reference,
                       action: :new,
                       card: { fields: { ":subject": card.name } } },
               title: title,
               "data-bs-toggle": "tooltip",
               "data-bs-placement": "bottom"
  end

  view(:bar_menu, cache: :never) { super() }
  # because attribution link has uncacheable content

  view :history_and_references do
    tabs "Contributions" => { content: render_history(hide: :title) },
         "References" => { content: field_nest(:reference, view: :content) }
  end

  view :att_wikirate do
    link_to "Wikirate.org", href: "https://wikirate.org", target: "_blank"
  end

  view :att_title do
    "'#{link_to attribution_title, href: render_id_url, target: '_blank'}' " \
      "by #{render_attribution_authorship}"
  end

  view :attribution_authorship do
    attribution_authors.map do |author_name|
      if (author_id = author_name.card_id)
        link_to author_name, href: card_url("~#{author_id}"), target: "_blank"
      else
        author_name
      end
    end.to_sentence
  end

  view :att_license do
    "licensed under #{link_to license_text, href: license_url, target: '_blank'}"
  end
end

format :csv do
  view :reference_dump_core do
    [].tap do |rows|
      card.each_reference_dump_row { |answer| rows << answer.csv_line(true) }
    end
  end
end
