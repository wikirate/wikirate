format :html do
  # @param type [:metric, :company]
  def next_button type
    navigate_button type, icon_tag(:chevron_right), next_item(type)
  end

  # @param type [:metric, :company]
  def previous_button type
    navigate_button type, icon_tag(:chevron_left), previous_item(type)
  end

  def navigate_button type, text, item
    opts = { class: "btn btn-outline-secondary btn-xs-icon mx-2" }
    if item
      opts[:path] = research_url(type => item)
    else
      add_class opts, "disabled"
    end
    link_to text, opts
  end

  def next_item type
    list = send("#{type}_list")
    index = list.index send(type)
    return if !index || index == list.size - 1

    list[index + 1]
  end

  def previous_item type
    list = send("#{type}_list")
    index = list.index send(type)
    return if !index || index.zero?

    list[index - 1]
  end

  def index type
    list = send("#{type}_list")
    list.index(send(type)) || 0
  end

  def list_count type
    list = send("#{type}_list")
    list.size
  end
end
