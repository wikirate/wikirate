# event :update_view_cache, :after=>:subsequent do
#   # ['Anonymous', 'Vishal Kapadia', 'Sebastian Jekutsch', "Ethan McCutchen"].each do |name|
#   #   Auth.as(name) do
#   #     render_views_for_cache
#   #   end
#   # end
# end


def render_views_for_cache
  args = {
    :denied_task=>nil,
    :home_view=>:open,
    :inc_name=>'_main',
    :inc_syntax=>"_main|open"
  }
  ['Home','Companies', 'Metrics', 'Topics', 'Overviews', 'Notes', 'Sources'].each do |name|
    Card.fetch(name).format.render_open(args)
  end
  args[:home_view] = :content
  args[:inc_syntac] = "_main|content"
  Card.fetch('home').format.render_open(args)
end