format :html do
  def bookmark_count
    @bookmark_count ||= Card::Bookmark.current_ids.size
  end

  def bookmark_text
    bookmarks = "bookmark".pluralize bookmark_count
    "Join to save #{bookmark_count} #{bookmarks}."
  end

  view :sign_up do
    voo.title = "Join"
    haml :sign_up_with_bookmarks, join_link: super()
  end

  before :sign_in do
    class_up "signin_link", "btn btn-outline-secondary"
    voo.title = "Log in"
  end

  before :sign_out do
    voo.title = "Log out"
  end
end
