format :html do
  include Right::GeneralOverview::HtmlFormat
  def default_param_key
    :edit_article
  end
end
