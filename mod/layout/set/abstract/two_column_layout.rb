include_set Abstract::Header
include_set Abstract::Tabs
include_set Abstract::Media

format do
  view :raw do
    ""
  end
end

format :html do
  view :open_content do
    two_column_layout
  end

  def two_column_layout col1=6, col2=6, row_hash={}
    bs_layout container: false, fluid: true, class: container_class do
      row_hash[:class] ||= "panel-margin-fix"
      row col1, col2, row_hash do
        column _render_left_column, class: left_column_class
        column _render_right_column, class: right_column_class
      end
    end
  end

  view :left_column do
    # had slot before
    output [_render_rich_header, _render_data]
  end

  view :right_column do
    _render_tabs
  end

  def container_class
    ""
  end

  def left_column_class
    "left-col"
  end

  def right_column_class
    "right-col"
  end

  view :rich_header do
    bs_layout do
      row 12 do
        col class: "p-0 rich-header border-bottom" do
          _render_rich_header_body
        end
      end
    end
  end

  view :rich_header_body do
    text_with_image title: "", text: header_right, size: :large
  end

  def header_image
    wrap_with :div, class: "image-box large-rect" do
      field_nest(:image, size: :large)
    end
  end

  def header_right
    wrap_with :h3, _render_title, class: "header-right"
  end

  view :data, cache: :never do
    wrap do
      [_render_filter, _render_table]
    end
  end
end
