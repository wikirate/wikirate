include_set Abstract::Utility
include_set Abstract::FilterQuery
include_set Abstract::FilterFormgroups

format :html do
  def view_caching?
    false
  end

  def page_link_params
    [:sort] + card.params_keys
  end

  def default_filter_form_args args
    args[:formgroups] =
      append_formgroup(card.default_keys).unshift(:sort_formgroup)
    args[:advanced_formgroups] = append_formgroup(card.advanced_keys)
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Alphabetical" => "name"
    }
  end

  view :no_search_results do |_args|
    %(
      <div class="search-no-results">
        No result
      </div>
    )
  end

  def filter_active?
    card.advanced_keys.any? { |key| Env.params[key].present? }
  end

  def wrap_as_collapse
    <<-HTML
     <div class="advanced-options">
      <div id="collapseFilter" class="collapse #{'in' if filter_active?}">
        #{yield}
      </div>
    </div>
    HTML
  end

  def default_button_formgroup_args args
    toggle_text = filter_active? ? "Hide Advanced" : "Show Advanced"
    buttons = [
      link_to_card(card.cardname.left_name, "Reset",
                   class: "slotter btn btn-default margin-8")
    ]
    unless card.advanced_keys.empty?
      buttons.unshift(content_tag(:a, toggle_text,
                                  href: "#collapseFilter",
                                  class: "btn btn-default",
                                  data: { toggle: "collapse",
                                          collapseintext: "Hide Advanced",
                                          collapseouttext: "Show Advanced" }))
    end
    args[:buttons] = buttons.join
  end

  def advanced_formgroups args
    advanced_formgroups = args[:advanced_formgroups]
    adv_html = ""
    if advanced_formgroups
      adv_html = wrap_as_collapse do
        advanced_formgroups.map { |fg| optional_render(fg, args) }.join("")
      end
    end
    adv_html.html_safe
  end

  view :filter_form do |args|
    formgroups = args[:formgroups] || [:name_formgroup]
    html = formgroups.map { |fg| optional_render(fg, args) }
    content = output(html) + advanced_formgroups(args)
    action = card.left.name
    <<-HTML
      <form action="/#{action}" method="GET">
        #{content}
        #{_optional_render :button_formgroup, args}
      </form>
    HTML
  end

  # it was from filter_search.rb
  # the filter args need to be included in the page link args
  # otherwise it will lose the filter condition while changing pages
  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    page_link_params.each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    options[:path] = @paging_path_args.merge filter_args
    link_to raw(text), options
  end
end
