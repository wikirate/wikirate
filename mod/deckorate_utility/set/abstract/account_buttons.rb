# note, abstracted this set because self/account_links/account_buttons.rb is
# interpreted as the self set for account_links+account_buttons. but we can't just put it
# in account_links.rb because of the super() call.
#
# we might not need this anymore, because we're not still doing bookmarks?

format :html do
  def bookmark_count
    @bookmark_count ||= Card::Bookmark.current_ids.size
  end

  def join_bookmark_text
    bookmarks = "bookmark".pluralize bookmark_count
    "Join to save #{bookmark_count} #{bookmarks}."
  end

  view :sign_up do
    haml :sign_up_with_bookmarks, join_link: super()
  end

  before :sign_in do
    class_up "signin_link", "btn btn-outline-secondary"
  end
end
