include_set Abstract::Table

format :html do
  view :core do
    field_nest(:description) + badge_tables.html_safe
  end

  def badge_tables
    [:metric_answer, :metric, :wikirate_company, :project, :source].map do |type|
      <<-HTML
           <h4>#{Card.fetch_name type}</h4>
           #{squad_overview type}
      HTML
    end.join
  end

  def squad_overview type
    wikirate_table :plain, badge_cards(type),
                   [:link_with_certificate, :description, :awarded],
                   td: {
                     classes: ["badge-name", "badge-description", "badge-count"]
                   }
  end

  def badge_cards squad_type
    Abstract::BadgeSquad.for_type(squad_type).badge_names.map do |name|
      Card[name]
    end.compact
  end
end
