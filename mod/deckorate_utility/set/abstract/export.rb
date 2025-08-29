EXPORT_LIMIT_OPTIONS = [50, 100, 500, 1000, 5000].freeze

# supports requiring signins for CSV and JSON downloads
module ExportPermissions
  def ok? task
    if task == :read && !Auth.signed_in? && !Auth.always_ok? # the always_ok is for as_bot
      card.deny_because "Must be signed in"
    else
      super
    end
  end
end

format do
  def export_filename
    "Wikirate-#{export_timestamp}-#{export_title}"
  end
  #
  # def default_limit
  #   Auth.signed_in? ? 5000 : 500
  # end
end

format :csv do
  include ExportPermissions

  view :header do
    with_metadata { [render_titles] }
  end

  # for override
  view :titles, perms: :none do
    %w[Link Name ID]
  end
end

format :json do
  include ExportPermissions

  view :titled do
    render_molecule
  end

  view :detailed do
    render_molecule items: { view: :molecule }
  end
end

format :html do
  view :export_panel, cache: :deep, template: :haml, wrap: :slot
  view :export_button, cache: :never, template: :haml, denial: :blank
  view :export_limit, cache: :never, template: :haml
  view :export_form_button, cache: :never, template: :haml

  view :export_hidden_tags, cache: :never do
    hidden_tags filter_and_sort_hash, nil, form: "export-form"
  end

  view :filtered_results_footer do
    super() + export_form
  end

  def export_form
    form_tag "/#{card.name.url_key}", id: "export-form", method: :get
  end

  def default_export_limit
    card.format(:base).default_limit
  end

  def export_limit_options
    options = EXPORT_LIMIT_OPTIONS.map { |num|  export_limit_option_label num }
    options_for_select options,
                       # disabled: export_limit_options_disabled,
                       selected: default_export_limit
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

  def export_views
    :titled
  end

  # for override
  def confirm_export
    nil
  end

  private

  # localize
  def export_limit_option_label num
    ["up to #{num}", num]
  end

  # def export_limit_options_disabled
  #   Auth.signed_in? ? [] : [1000, 5000]
  # end
end
