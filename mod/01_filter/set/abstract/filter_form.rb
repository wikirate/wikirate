def virtual?
  true
end

format :html do
  include Set::Abstract::Filter::HtmlFormat
  def filter_categories
    []
  end

  def filter_active?
    Env.params.keys.any? { |key| filter_categories.include? key }
  end

  def content_view
    :content_left_col
  end

  def default_button_formgroup_args args
    args[:buttons] = [
      card_link(card.cardname.left, path_opts: { view: content_view },
                                    text: "Reset",
                                    class: "slotter btn btn-default margin-8",
                                    remote: true),
      button_tag("Filter", situation: "primary", disable_with: "Filtering")
    ].join
  end

  view :core do |args|
    action = card.cardname.left_name.url_key
    filter_active = filter_active? ? "block" : "none"
    <<-HTML
    <div class="filter-container">
        <div class="filter-header">
          <span class="glyphicon glyphicon-filter"></span>
          Filter & Sort
          <span class="filter-toggle">
            <span class="glyphicon glyphicon-triangle-right"></span>
          </span>
        </div>
        <div class="filter-details" style="display: #{filter_active};">
          <form action="/#{action}?view=#{content_view}" method="GET" data-remote="true" class="slotter">
            #{filter_form_content(args)}
          </form>
        </div>
    </div>
    HTML
  end

  def filter_form_content _args
    "fill me"
  end
end
