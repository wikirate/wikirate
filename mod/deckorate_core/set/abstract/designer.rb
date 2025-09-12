format :html do
  view :designer_box, template: :haml

  view :designer_box_top do
    render_title_link
  end

  view :designer_box_bottom do
    count_badges :metric, :answer
  end
end