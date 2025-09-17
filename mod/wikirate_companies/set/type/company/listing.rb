include_set Abstract::Thumbnail

format :html do
  mini_bar_cols 7, 5

  def thumbnail_title
    voo.show :title_link if voo.show? :thumbnail_link
    output [render_title, render_headquarters(optional: :hide)]
  end

  def thumbnail_subtitle
    render :identifiers_list, optional: :show
  end

  view :headquarters do
    field_nest :headquarters, view: :content, unknown: :blank, items: { view: :name }
  end

  # TODO: explain?
  view :unknown do
    _render_link
  end

  view :bar_left do
    render_thumbnail show: :headquarters
  end

  view :bar_right do
    [count_badges(:metric, :answer), render_bookmark]
  end

  view :bar_middle do
    result_middle { count_badges :source, :dataset }
  end

  view :bar_bottom do
    output [render_bar_middle, render_details_tab]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :answer
  end

  view :designer_box_bottom do
    count_badges :metrics_designed, :answers_designed
  end
end
