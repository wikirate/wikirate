format do
  view :cite, closed: true do
    ""
  end
end

format :html do
  attr_accessor :citations

  view :cite, cache: :never do
    # href_root = parent ? parent.card.name.trunk_name.url_key : ''
    wrap_with :sup do
      wrap_with :a, class: "citation", href: "##{card.name.url_key}" do
        cite!
      end
    end
  end

  def cite!
    holder = parent.parent || parent || self
    holder.citations ||= []
    holder.citations << card.key
    holder.citations.size
  end
end
