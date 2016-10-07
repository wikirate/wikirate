include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout


format :html do
  def tab_list
    {
      details_tab: "Details",
      # open_corporates_tab: "OpenCorporates",
      projects_tab: "Projects",
      topics_tab: tab_count_title("Topics", :wikirate_topic),
      sources_tab: tab_count_title("Sources", :source)
    }
  end


  view :table do |args|
    _render_metric_list(args)
  end

  view :rich_header do |args|
    bs_layout do
      row sm: [6, 6], xs: [3, 9] do
        col do
          div class: "image-box large-rect" do
            field_nest(:image, size: :large)
          end
        end
        col do
          content_tag :h2, _render_title, class: "company-color"
        end

      end
    end
  end

  # view :core do |args|
  #   tabs = [
  #     ["metric", "Metrics", "+metric+*cached count"],
  #     ["topic", "Topics", "+topic+*cached count"],
  #     #["topic", "Projects", "+topic+*cached count"],
  #     #["overview", "Reviews", "+analyses with overview+*cached count"],
  #     #["note", "Notes", "+Note+*cached count"],
  #     ["reference", "Sources", "+sources+*cached count"]
  #   ]
  #   wikirate_layout "company", tabs, render_contribution_link(args)
  # end

  view :topics_tab do |args|

    "Ghost"
    # process_content <<-HTML
    #   <div class="voting">
    #
    #      {{_left+topic+upvotee search|drag_and_drop|content;structure:company topic drag item}}
    #
    #     #{nest "topic votee filter", view: :core}
    #      <div class="header-row">
    #        <div class="header-header">Topic</div>
    #         <div class="data-header">Contributions</div>
    #      </div>
    #     {{_left+topic+novotee search|drag_and_drop|content;structure:company topic drag item}}
    #     {{_left+topic+downvotee search|drag_and_drop|content;structure:company topic drag item}}
    #   </div>
    # HTML
  end

  view :details_tab do |args|
    "Details"
  end

  view :projects_tab do |args|
    "projects"
  end

  view :sources_tab do |args|
    field_nest(:source, view: :content, items: { view: :source_list_item })
  end

  view :filter do |args|
    field_subformat(:company_metric_filter)._render_core args
  end

  view :metric_list do
    yinyang_list field: :all_metric_values, row_view: :metric_row_for_company
  end
end