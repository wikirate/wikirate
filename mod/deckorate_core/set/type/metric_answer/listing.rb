include_set Abstract::Media
include_set Abstract::Table

# views used in answer listings on metric, company, and profile pages

format :html do
  view :bar_left do
    wrap_with :div, class: "d-block" do
      [company_thumbnail(card.company, hide: :thumbnail_subtitle),
       render_metric_thumbnail]
    end
  end

  view :company_thumbnail do
    company_thumbnail card.company, hide: :thumbnail_link
  end

  view :company_thumbnail_with_bookmark do
    nest card.company_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
  end
end
