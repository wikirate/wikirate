include_set Abstract::Table

format :html do
  view :core do
    [:metric_value, :metric, :wikirate_company, :project, :source].map do |type|
      <<-HTML
       <h4>#{Card.fetch_name}</h4>
       #{squad_overview type}
      HTML
    end
  end

  def squad_overview type
    wikirate_table :plain, badge_cards(type),
                   [:link_with_certificate, :description, :awarded]
  end

  def badge_cards squad_type
    Abstract::BadgeSquad.from_type(squad_type).badge_names.map do |name|
      Card[name]
    end.compact
  end
end
