include_set Abstract::Header
include_set Abstract::Tabs
include_set Abstract::Media

format do
  view :raw do
    ""
  end
end

format :html do
  def layout_name_from_rule
    :wikirate_two_column_layout
  end

  before :open do
    voo.hide :header
    voo.show :menu
  end

  view :open_content do
    two_column_layout
  end

  view :left_column do
    # had slot before
    output [naming { render_rich_header }, _render_data]
  end

  view :right_column do
    add_name_context
    [render_tabs, render_type_link]
  end

  view :data, cache: :never do
    wrap do
      [_render_filter, _render_table]
    end
  end

  def two_column_layout col1=6, col2=6, row_hash={}
    bs_layout container: false, fluid: true, class: container_class do
      row_hash[:class] ||= "panel-margin-fix two-column-box"
      row col1, col2, row_hash do
        column _render_left_column, class: left_column_class
        column _render_right_column, class: right_column_class
      end
    end
  end


  # OVERRIDE

  def container_class
    ""
  end

  def left_column_class
    "left-col"
  end

  def right_column_class
    "right-col"
  end
end
