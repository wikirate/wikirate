format :html do
  def bs_badge count, label, klass=nil
    @badge_count = count
    @badge_label = label
    @badge_class = klass
    haml
  end

  view :bs_badge, template: :haml
  view :bs_badge_content, template: :haml
end
