EXPORT_LIMIT_OPTIONS = [50, 100, 500, 1000, 5000].freeze

format do
  def export_filename
    "WikiRate-#{export_timestamp}-#{export_title}"
  end
end

format :html do
  view :export_panel, cache: :never, template: :haml, wrap: :slot

  view :export_button, cache: :never, template: :haml

  def export_limit_options
    options = EXPORT_LIMIT_OPTIONS.map { |num|  export_limit_option_label num }
    options_for_select options,
                       disabled: export_limit_options_disabled,
                       selected: export_limit_option_selected
  end

  def export_modal_link text, opts={}
    opts[:path] = filter_and_sort_hash.merge(mark: card.name, view: :export_panel)
    modal_link text, opts
  end

  # localize
  def export_item_limit_label
    type_name = card.item_type_name
    type_name.present? ? type_name&.vary(:plural) : "Items"
  end

  private

  # localize
  def export_limit_option_label num
    ["up to #{num}", num]
  end

  def export_limit_options_disabled
    Auth.signed_in? ? [] : [1000, 5000]
  end

  def export_limit_option_selected
    Auth.signed_in? ? 5000 : 500
  end
end
