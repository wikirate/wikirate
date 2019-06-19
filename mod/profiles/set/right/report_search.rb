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

def cache_query?
  false
end

# part 3 of U+C+R
def research_group_name
  name.left_name.right_name
end

def research_group_card
  @research_group_card ||= Card.fetch research_group_name if research_group?
end

def wql_content
  research_group? ? research_group_report_query : standard_report_query
end

def standard_report_query
  cardtype_card.report_query variant, user_card.id, subvariant
end

def research_group_report_query
  type_ids = cardtype_card.ids_related_to_research_group research_group_card
  type_ids = [-1] if type_ids.empty? # TODO: cleaner way to force 0 result
  standard_report_query.merge id: [:in, type_ids]
end

# created, updated, voted on, etc.
def variant
  @variant ||= (Env.params["variant"]&.to_sym) || :created
end

# eg voted for/voted against
def subvariant
  @subvariant ||= (Env.params["subvariant"]&.to_sym) || :all
end

def subvariant_count subvariant
  selected = @subvariant
  @subvariant = subvariant
  result = Card.search wql_hash.merge(return: :count)
  @subvariant = selected
  result
end

format do
  def extra_paging_path_args
    { variant: variant, subvariant: subvariant, view: :list }
  end
end

format :html do
  delegate :subvariant, to: :card

  # FIXME: shouldn't have to specify limit so many times!
  def limit
    5
  end

  def default_limit
    5
  end

  # uses structure to hold variant
  # (so that it can be passed around via slot options)

  def variant
    card.variant = voo.structure if voo.structure
    card.variant&.to_sym
  end

  def subvariants
    return unless variant
    card.cardtype_card.subvariants[variant]
  end

  def subvariant_tabs
    subvariants.unshift(:all).each_with_object({}) do |key, h|
      h[key] = { title: subvariant_tab_title(key), path: subvariant_tab_path(key) }
    end
  end

  def subvariant_tab_title key
    "#{key.to_s.tr('_', ' ')} <span class='badge'>#{card.subvariant_count(key)}</span>"
  end

  def subvariant_tab_path key
    path subvariant: key, variant: variant, view: :list
  end

  view :core, cache: :never do
    # without this, variant is lost with view caching on.
    variant
    super()
  end

  view :list_with_subtabs do
    if subvariants
      lazy_loading_tabs subvariant_tabs, subvariant, render_list, type: "pills"
    else
      render_list
    end
  end

  view :list do
    _render_content structure: variant, items: { view: :bar }
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
