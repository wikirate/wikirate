EXPORT_LIMIT_OPTIONS = [50, 100, 500, 1000, 5000].freeze

format do
  def export_filename
    "Wikirate-#{export_timestamp}-#{export_title}"
  end

  def default_limit
    Auth.signed_in? ? 5000 : 500
  end
end

format :csv do
  view :header do
    with_metadata { [render_titles] }
  end

  # for override
  view :titles do
    %w[Link Name ID]
  end
end

format :json do
  view :titled do
    render_molecule
  end

  view :detailed do
    render_molecule items: { view: :molecule }
  end

  def page_details obj
    super.tap { |hash| cache_url hash }
  end

  def cache_url hash
    return unless ENV["CACHE_JSON"]

    hash[:url] = "/cached/#{card.name.url_key}.json"
  end
end

format :html do
  view :export_panel, template: :haml, wrap: :slot
  view :export_button, cache: :yes, template: :haml, denial: :blank
  view :export_limit, cache: :never, template: :haml

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
                       disabled: export_limit_options_disabled,
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

  def export_limit_options_disabled
    Auth.signed_in? ? [] : [1000, 5000]
  end
end
