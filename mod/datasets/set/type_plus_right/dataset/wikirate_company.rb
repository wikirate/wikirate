# These Dataset+Company (type plus right) cards refer to the list of
# all companies on a given dataset.
include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Right::BrowseCompanyFilter
include_set Abstract::DatasetScope
include_set Abstract::IdPointer

def item_cards_for_validation
  item_cards.sort_by(&:key)
end

def cql_content
  { referred_to_by: "_"}
end

def item_cards args={}
  return item_cards_search(args) if args[:complete]
  return known_item_cards(args) if args[:known_only]

  all_item_cards args
end

def count
  item_strings.size
end


format :html do


  def filter_field_code
    :browse_company_filter
  end
end
