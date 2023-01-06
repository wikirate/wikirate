# include_set Abstract::SolidCache, cached_format: :html
#
# cache_expire_trigger Card::Set::All::Base do |_changed_card|
#   Card[:homepage] if Codename.exist? :homepage
# end

def new_relic_label
  "home"
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

  %i[core top_banner footer].each do |view|
    view view, template: :haml
  end

  def edit_fields
    []
  end
end
