# TODO: abstract and put in bookmarks mod

# cache # of users who have bookmarked this metric/topic/whatever(=left)
include_set Abstract::TaggedByCachedCount, type_to_count: :user,
                                           tag_pointer: :bookmarks,
                                           count_trait: :bookmarkers

format :html do
  def bookmark_status_class
    card.active? ? "#{card.left.type_name.key}-color" : "inactive-bookmark"
  end
end
