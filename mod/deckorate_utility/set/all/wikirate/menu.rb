format :html do
  def bar_menu_items
    [
      full_page_link(text: "Open in full page"),
      new_window_link(text: "Open in new window"),
      modal_page_link(text: "Open in modal"),
      edit_link(:edit, text: card.unknown? ? "Create" : "Edit"),
      board_link(text: "Advanced")
    ]
  end

  def menu_items
    [history_link, menu_edit_link, menu_board_link]
  end

  # Generates a history link with optional parameters.
  #
  # @param [String] text The text displayed on the link.
  # @param [String] title ("History") The title attribution of the link tag.
  #
  # @return [String] The HTML code for the history link.
  #
  # @example
  #   history_link(text: "Timeline", title: "View Timeline History")
  def history_link text: "", title: "View History"
    modal_link "#{icon_tag :history} #{text}",
               size: :large,
               rel: "nofollow",
               path: { view: history_view, slot: { hide: :title } },
               title: title,
               "data-bs-toggle": "tooltip",
               "data-bs-placement": "bottom"
  end

  def history_view
    :history
  end
end
