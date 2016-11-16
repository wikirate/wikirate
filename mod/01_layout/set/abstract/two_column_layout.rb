include_set Abstract::Header
include_set Abstract::Tabs

format :html do
  def default_open_content_args args
    args[:left_class] ||= { class: "left-col nopadding" }
    args[:right_class] ||= { class: "right-col" }
    args[:grid_option] ||= { md: [6, 6] }
  end

  view :open_content do |args|
    bs_layout container: true, fluid: true,
              class: @container_class do
      row 6, 6 do #args[:grid_option] do
        column _render_content_left_col, args[:left_class]
        column _render_content_right_col, args[:right_class]
      end
    end
  end

  view :content_right_col do |args|
    _render_tabs(args)
  end

  view :content_left_col do |args|
    # had slot before
    output [
             _render_rich_header(args),
             _render_data(args)
           ]
  end

  view :data do |args|
    wrap do
      [
        _optional_render_filter(args),
        _render_table(args)
      ]
    end
  end
end

