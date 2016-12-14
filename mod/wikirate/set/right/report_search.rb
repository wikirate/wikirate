include_set Abstract::Table

# "+report search" cards are virtual cards used to manage searches for
# contribution reports

# In the context of a User Profile page, these reports take the form of
#   [User]+[Cardtype]+report search

# In the context of a Research Group page, the reports take the form of
#   [User]+[Cardtype]+[Research Group]+report search

# In both cases, the report queries can only vary structurally by cardtype
# (not by user or research_group), so the query methods are defined on the
# cardtype set modules (eg self/metric).

attr_accessor :variant

def user_plus_cardtype_name
  @user_plus_cardtype_name ||=
    research_group? ? cardname.left_name.left_name : cardname.left_name
end

def user_card
  @user_card ||= Card.fetch user_plus_cardtype_name.left
end

def cardtype_card
  @cardtype_card ||= Card.fetch user_plus_cardtype_name.right
end

def research_group?
  if @research_group.nil?
    @research_group = cardname.parts.size > 3
  else
    @research_group
  end
end

def research_group_name
  cardname.right_name
end

def research_group_card
  @research_group_card ||= Card.fetch research_group_name if research_group?
end

def raw_ruby_query _overide={}
  research_group? ? research_group_report_query : standard_report_query
end

def standard_report_query
  cardtype_card.report_query variant, user_card.id
end

def research_group_report_query
  cardtype_card.research_group_report_query(
    variant, user_card.id, research_group_card.id
  )
end

format :html do
  # uses structure to hold variant
  # (so that it can be passed around via slot options)

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
                       header: %(Metric Company Answer)
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
