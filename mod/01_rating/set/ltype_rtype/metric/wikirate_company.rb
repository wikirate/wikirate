def latest_value_year
  cached_count
end

def latest_value_card
  return if !(lvy = latest_value_year) || lvy == 0
  Card.fetch "#{name}+#{latest_value_year}"
end

def company_card
  right
end

def company_name
  company_card.cardname
end

def company
  cardname.tag
end

format :html do
  def default_menu_args args
    args[:optional_horizontal_menu] = :hide
  end

  view :all_values do |args|
    wql = { left: card.name,
            type: Card::MetricValueID,
            sort: "name",
            dir: "desc"
          }
    wql_comment = "all metric values where metric = #{card.name}"
    Card.search(wql, wql_comment).map.with_index do |v, i|
      <<-HTML
        <span data-year="#{v.year}" data-value="#{v.value}"
              #{'style="display: none;"' if i > 0}>
          #{subformat(v).render_concise(args)}
        </span>
      HTML
    end.join("\n")
  end

  view :image_link do
    # TODO: change the css so that we don't need the extra logo class here
    #   and we can use a logo_link view on the type/company set
    text = content_tag :div, class: "logo" do
      card.company_card.format.field_nest :image, view: :core, size: "small"
    end
    card_link card.company_card, class: "inherit-anchor hidden-xs",
                                 text: text
  end

  view :name_link do
    card_link card.company_card,
              class: "inherit-anchor",
              text: content_tag(:div, card.company, class: "name")
  end

  view :yinyang_row do |args|
    append_name =
      if card.left.metric_type_codename == :score
        "score_metric_details_company_header"
      else
        "metric_details_company_header"
      end
    wrap(args) do
      <<-HTML
      <div class="yinyang-row">
        <div class="company-item value-item">
          <div class="header">
            #{_render_image_link}
            #{_render_name_link}
          </div>
          <div class="data metric-details-toggle"
               data-append="#{append_name}">
            <div class="data-item">
              #{_render_all_values(args)}
            </div>
          </div>
          <div class="details">
          </div>
        </div>
      </div>
    HTML
    end
  end
end
