include_set Abstract::SolidCache, cached_format: :html

def new_relic_label
  "home"
end

cache_expire_trigger Card::Set::All::Base do |_changed_card|
  Card[:homepage]
end

format :html do
  layout :home_layout, view: :content do
    <<-HTML.strip_heredoc
      <body class="wikirate-layout home-layout">
        #{nest :nav_bar, view: :core}
        #{layout_nest}
      </body>
    HTML
  end

  def layout_name_from_rule
    :home_layout
  end

  %i[core top_banner video_section numbers projects organizations footer].each do |view|
    view view, template: :haml
  end

  def edit_fields
    [:homepage_solution_text,
     :homepage_project_text,
     :homepage_topic_text,
     :homepage_adjectives,
     %i[wikirate_company featured],
     %i[wikirate_topic featured],
     %i[project featured],
     %i[metric_answer featured],
     :organizations_using_wikirate].map { |f| [f, { absolute: true }] }
  end

  def companies
    Card[:wikirate_company, :featured].item_names
  end

  def topics
    Card[:wikirate_topic, :featured].item_names.map { |n| words_after_colon n }
  end

  def featured_answers
    Card[%i[metric_answer featured]].item_names
  end

  def words_after_colon string
    string.gsub(/^.*\:\s*/, "")
  end

  def adjectives
    Card[:homepage_adjectives].item_names
  end

  def organization_cards
    Card.fetch(:organizations_using_wikirate).item_cards
  end

  Category = Struct.new :codename, :title, :count, :color

  def categories
    [
      category(:wikirate_company, rate_subjects, :company),
      category(:metric, "Metric Questions", :metric),
      category(:metric_answer, "Metric Answers", :answer),
      category(:source, "Sources", :source)
    ]
  end

  def category codename, title, color
    Category.new codename, title, category_count(codename), color
  end

  def category_count card_type
    nest card_type, view: :count
  end
end
