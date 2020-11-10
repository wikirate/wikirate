format :html do
  def quick_filter_item hash, filter_key
    icon = hash.delete :icon
    super.tap do |item|
      item[:icon] = icon || mapped_icon_tag(filter_key)
    end
  end
end
