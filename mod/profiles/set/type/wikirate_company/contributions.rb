card_reader :projects_organized, type: :search_type
card_reader :metrics_designed, type: :search_type

format :html do
  def contrib_page?
    return @contrib_page unless @contrib_page.nil?
    param = Env.params[:contrib]
    @contrib_page = contribs_made? ? param != "N" : param == "Y"
  end

  view :contributions_data do
    field_nest :metrics_designed, view: :titled
  end

  # NOCACHE because of special contributor handling
  view :type_link, cache: :never do
    super()
  end

  view :contrib_switch, cache: :never do
    contrib_page? ? switch_to_performance : switch_to_contrib
  end

  def switch_to_performance
    switch_to "Performance", :wikirate_company, "N", "Company performance profile"

  end

  def switch_to_contrib
    switch_to "Contributions", :user, "Y", "Content contributions to WikiRate.org"
  end

  def switch_to text, icon, val, title
    link_to_card card, "#{text} #{mapped_icon_tag icon}",
                 class: "company-switch", title: title, path: { contrib: val }
  end

  def type_link_label
    contrib_page? ? "Organizational Contributor" : super
  end

  def type_link_icon
    mapped_icon_tag(contrib_page? ? :user : :wikirate_company)
  end

  def contribs_made?
    Card.cache.fetch "#{card.id}-CONTRIB" do
      metrics_designed? || projects_organized?
      # only updates with cache clearing.  fine for now...
    end
  end

  def metrics_designed?
    card.metrics_designed_card.count.positive?
  end

  def projects_organized?
    card.projects_organized_card.count.positive?
  end

  view :projects_organized_tab do
    field_nest :projects_organized, view: :content
  end
end
