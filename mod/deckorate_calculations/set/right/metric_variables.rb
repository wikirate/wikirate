
format :html do



  def slot_selector view
    "#{card.patterns.first.safe_key}.#{view}-view"
  end

  def add_variable_button klass, slot_selector, filters={}
    opts =
      modal_link_opts class: "_add-metric-variable #{klass} btn btn-outline-secondary",
                      path: add_variable_path(slot_selector, filters),
                      size: :full

    wrap_with :span, class: "input-group" do
      link_to "#{fa_icon(:plus)} add metric", opts
    end
  end

  def add_variable_path slot_selector, filters
    {
      view: :filter_items_modal,
      item: implicit_item_view,
      filter_card: filter_card.name,
      item_selector: "thumbnail",
      slot_selector: slot_selector,
      slot: { hide: :modal_footer },
      filter: initial_filters(filters)
    }
  end

  # TODO: make sure card.metric_card.id remains in not_id filters
  # currently it only limits the initial filter.
  def not_ids
    card.item_ids.push(card.metric_card.id).compact.map(&:to_s).join(",")
  end

  def initial_filters added_filters
    { not_ids: not_ids }.merge added_filters
  end
end
