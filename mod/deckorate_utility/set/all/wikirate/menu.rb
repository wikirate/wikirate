format :html do
  def bar_menu_items
    [
      full_page_link(text: "Open in full page"),
      new_window_link(text: "Open in new window"),
      modal_page_link(text: "Open in modal"),
      edit_link(:edit, text: card.new? ? "Create" : "Edit"),
      board_link(text: "Advanced")
    ]
  end

  def menu_items
    [menu_edit_link, menu_board_link]
  end
end
