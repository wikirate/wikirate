format :html do
  def item_view type
    case type
    when :year then :name
    when :source then :compact
    else :thumbnail
    end
  end
end
