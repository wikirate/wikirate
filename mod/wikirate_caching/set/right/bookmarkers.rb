<<<<<<< HEAD
# TODO: abstract and put in bookmarks mod

# cache # of users who have bookmarked this metric/topic/whatever(=left)
include_set Abstract::ListRefCachedCount,
            type_to_count: :user,
            list_field: :bookmarks,
            count_trait: :bookmarkers

=======
>>>>>>> main
format :html do
  def bookmark_status_class
    card.active? ? "#{card.left.type_name.key}-color" : "inactive-bookmark"
  end
end
