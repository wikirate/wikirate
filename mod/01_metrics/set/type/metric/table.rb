format :html do
  def company_count
    card.fetch(trait: :wikirate_company).cached_count
  end

  view :company_count do
    company_count
  end

  view :thumbnail_with_vote do
    voo.hide! :thumbnail_subtitle
    output [
               _render_vote,
               _render_thumbnail
           ]
  end

  view :latest_value do
    field_subformat(:latest_value)._render_concise
  end

  view :details do
    <<-HTML
      <div class="data-item show-with-details text-center">
        <span class="label label-metric">[[_l|Metric Details]]
        </span>
      </div>
    HTML
  end
end
