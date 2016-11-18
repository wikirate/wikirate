include_set Abstract::SpecialFilterForm

format :html do
  def filter_header
    <<-HTML
      <div class="filter-header" data-toggle="collapse"
              data-collapse-icon-in="glyphicon-triangle-right"
              data-collapse-icon-out="glyphicon-triangle-bottom"
              data-target=".filter-details">
        <span class="glyphicon glyphicon-filter"></span>
          #{filter_title}
       <span class="filter-toggle glyphicon glyphicon-triangle-right"></span>
      </div>
    HTML
  end

  def filter_title
    "Filter & Sort"
  end

  view :core do
    action = card.cardname.left_name.url_key
    filter_active = filter_active? ? "in" : "out"
    <<-HTML
    <div class="filter-container">
        #{filter_header}
        <div class="filter-details collapse #{filter_active}">
          <form action="/#{action}?view=#{content_view}" method="GET" data-remote="true" class="slotter">
            #{filter_form}
          </form>
        </div>
    </div>
    HTML
  end

  def filter_form
  <<-HTML
      <div class="margin-12 sub-content">
        #{main_filter_formgroups}
        #{_optional_render_sort_formgroup}
      </div>
      <hr/>
      <div class="filter-buttons">
        #{filter_button_formgroup}
      </div>
  HTML
  end
end
