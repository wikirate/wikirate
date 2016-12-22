include_set Abstract::WikirateTable

def latest_value_year
  cached_count
end

def latest_value_card
  return if !(lvy = latest_value_year) || lvy == 0
  Card.fetch cardname, lvy.to_s
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

def metric_name
  cardname.left
end

def metric
  left
end

format :html do
  def default_menu_args args
    args[:optional_horizontal_menu] = :hide
  end

  view :all_values do |args|
    wql = {
      left: card.name,
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
    text = wrap_with :div, class: "logo" do
      card.company_card.format.field_nest :image, view: :core, size: "small"
    end
    link_to_card card.company_card, text, class: "inherit-anchor hidden-xs"
  end

  view :name_link do
    link_to_card card.company_card, nil, class: "inherit-anchor name",
                                         target: "_blank"
  end
end
