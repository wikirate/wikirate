format :html do
  def google_analytics_snippet_vars
    super.insert(1, [:_setPageGroup, 1, card.type_name]).insert 2, ["_gat._anonymizeIp"]
  end
end
