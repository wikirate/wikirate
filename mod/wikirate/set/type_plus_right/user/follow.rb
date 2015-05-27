format :html do

  view :title do |args|
    res = super(args)
    res += view_link 'View ignored list', :ignoring_list
  end
  view :open_content do |args|
    _render_following_list(args)
  end
end