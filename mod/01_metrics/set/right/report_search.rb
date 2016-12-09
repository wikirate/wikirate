include_set Abstract::Table
#User+(Cardtype+report_search)

attr_accessor :variant

# contribution type card  optimize?
def cont_type_card
  @cont_type_card ||= Card.fetch cardname.left_name.right
end

def user_card
  @user_type_card ||= Card.fetch cardname.left_name.left
end

def raw_content
  cont_type_card.send "#{variant}_report_content", user_card.id
end

format :html do
  view :core do
    card.variant = voo.structure if voo.structure
    super()
  end

  view :metric_value_list do
    card.variant = voo.structure if voo.structure
    wrap do
      with_paging do
        wikirate_table :metric,
                       search_results,
                       [:metric_thumbnail, :company_thumbnail, :concise],
                       header: ["Metric", "Company", "Answer"]
      end
    end
  end

  view :metric_list do
    default_listing
  end
  view :wikirate_company_list do
    default_listing
  end
  view :project_list do
    default_listing
  end
  view :wikirate_topic_list do
    default_listing
  end
  view :source_list do
    default_listing
  end
  view :claim_list do
    default_listing
  end

  def default_listing item_view=:listing
    _render_content structure: card.variant,
                    skip_perms: true,
                    items: { view: item_view }
  end
end
