# Include with options :type_to_count and :tag
# counts all cards of a type "type_to_count" that are tagged with self via a
# +<tag_pointer> pointer.
# If <type_to_count>+<tag_pointer> card is updated, all
# <changed item name>+<type_to_count> cached counts are updated
#
# @example count for topic cards the metrics that are tagged with the topic
# via a +topic card
#   include_set Abstract::TaggedByCachedCount type_to_count: :metric,
#                                             tag_pointer: :wikirate_topic

include_set Abstract::SearchCachedCount

def self.included host_class
  host_class.class_eval do
    include_set Abstract::CachedCount
    recount_trigger :type_plus_right,
                    host_class.type_to_count,
                    host_class.tag_pointer do |changed_card|
      names = Abstract::CachedCount.pointer_card_changed_card_names(changed_card)
      names.map do |item_name|
        Card.fetch item_name.to_name.trait(host_class.type_to_count)
      end
    end

    define_method :wql_content do
      { type_id: Card::Codename.id(host_class.type_to_count), right_plus: right_plus_val }
    end

    define_method :right_plus_val do
      [Card::Codename.id(host_class.tag_pointer), { refer_to: left.id }]
    end
  end
end

# FIXME: hack. otherwise filter wql can overwrite right_plus
def filter_wql
  wql = super
  wql[:right_plus] = [wql[:right_plus], right_plus_val].compact
  wql
end
