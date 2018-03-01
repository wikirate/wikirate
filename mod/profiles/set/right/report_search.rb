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
    research_group? ? name.left_name.left_name : name.left_name
end

def user_card
  @user_card ||= Card.fetch user_plus_cardtype_name.left
end

def cardtype_card
  @cardtype_card ||= Card.fetch user_plus_cardtype_name.right
end

def research_group?
  if @research_group.nil?
    @research_group = name.parts.size > 3
  else
    @research_group
  end
end

# part 3 of U+C+R
def research_group_name
  name.left_name.right_name
end

def research_group_card
  @research_group_card ||= Card.fetch research_group_name if research_group?
end

def wql_hash
  research_group? ? research_group_report_query : standard_report_query
end

def standard_report_query
  cardtype_card.report_query variant, user_card.id, selected_subvariant
end

def research_group_report_query
  type_ids = cardtype_card.ids_related_to_research_group research_group_card
  type_ids = [-1] if type_ids.empty? # TODO: cleaner way to force 0 result
  standard_report_query.merge id: [:in, type_ids]
end

def selected_subvariant
  @subvariant ||=
    (Env.params["subvariant"]&.to_sym) || :all
end

def variant
  @variant ||=
    (Env.params["variant"]&.to_sym) || :created
end

def subvariant_count subvariant
  selected = @subvariant
  @subvariant = subvariant
  result = Card.search wql_hash.merge(return: :count)
  @subvariant = selected
  result
end

format :html do
  def extra_paging_path_args
    {
      variant: variant,
      subvariant: card.selected_subvariant,
      view: sublist_view
    }
  end

  # uses structure to hold variant
  # (so that it can be passed around via slot options)

  delegate :selected_subvariant, to: :card

  def variant
    card.variant&.to_sym
  end

  def subvariants
    return unless variant
    card.cardtype_card.subvariants[variant]
  end

  def subvariant_tabs
    subvariants.unshift(:all).each_with_object({}) do |key, h|
      h[key] = { title: subvariant_tab_title(key),
                 path: subvariant_tab_path(key) }
    end
  end

  def subvariant_tab_title key
    "#{key.to_s.tr('_', ' ')} <span class='badge'>#{card.subvariant_count(key)}</span>"
  end

  def subvariant_tab_path key
    path subvariant: key, variant: variant,
         view: sublist_view
  end

  def sublist_view
    "#{card.cardtype_card.codename}_sublist"
  end

  view :core do
    card.variant = voo.structure if voo.structure
    super()
  end

  view :wikirate_company_sublist do
    card.variant = voo.structure if voo.structure
    wrap do
      with_paging do
        wikirate_table :company,
                       search_with_params,
                       [:listing_compact],
                       header: %w[Company]
      end
    end
  end

  view :wikirate_topic_sublist do
    card.variant = voo.structure if voo.structure
    wrap do
      with_paging do
        wikirate_table :company,
                       search_with_params,
                       [:listing_compact],
                       header: %w[Topic]
      end
    end
  end

  view :metric_value_sublist do
    card.variant = voo.structure if voo.structure
    wrap do
      with_paging do
        wikirate_table :metric,
                       search_with_params,
                       [:metric_thumbnail, :company_thumbnail, :concise],
                       header: %w[Metric Company Answer]
      end
    end
  end

  def tab_listing content
    card.variant = voo.structure if voo.structure
    lazy_loading_tabs subvariant_tabs, selected_subvariant, content,
                      type: "pills"
  end

  def self.define_tab_listing_where_applicable cardtype
    return if cardtype.in? [:metric_value, :wikirate_company, :wikirate_topic]
    view "#{cardtype}_sublist" do
      card.variant = voo.structure if voo.structure
      default_listing
    end
  end

  [
    :metric,
    :project,
    :research_group,
    :source,
    :wikirate_company,
    :wikirate_topic,
    :metric_value
  ].each do |cardtype|
    view "#{cardtype}_list" do
      listing = render!("#{cardtype}_sublist".to_sym)
      return listing if card.research_group? || !subvariants
      tab_listing listing
    end

    define_tab_listing_where_applicable cardtype
  end

  def default_listing item_view=:listing
    _render_content structure: card.variant,
                    skip_perms: true,
                    items: { view: item_view, hide: :listing_middle }
  end

  # this is a bit of a hack but a reasonably safe one
  # +report search cards use voo.structure to carry the variant around
  # that same voo.structure flags to the nest mechanism that there could be
  # a recursion risk and makes it use a new subformat, which is a problem
  # here because that kills the paging.
  # as these cards are narrowly used, there is not much risk of recursion
  def nest_recursion_risk? _view
    false
  end
end
