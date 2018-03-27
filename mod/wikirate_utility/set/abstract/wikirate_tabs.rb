format :html do
  def list_entry name, label, count_card_name
    count = field_subformat(count_card_name)._render_core
    link_text =
      <<-HTML
        <span class="count-number clearfix">#{count}</span>
        <span class="count-label">#{label}</span>
      HTML
    link_to_card card, link_text,
                 path: { tab: name },
                 "data-tab-name" => name,
                 "data-tab-content-url" =>
                   path(mark: [card.name, "#{name}_page"])
  end

  def tab_list tabs
    lis = tabs.map do |args|
      list_entry(*args)
    end
    list_tag lis, class: "nav nav-tabs with-item-count text-center"
  end

  # def wikirate_layout type, tabs, extra=nil
  #   bs do
  #     layout container: true, fluid: true, class: "yinyang nodblclick" do
  #       row 6 do
  #         col class: "border-right" do
  #           row md: 12, xs: 12,
  #               class: "clearfix #{type}-content #{type}-page-logo-container" do
  #             col class: "m-0 p-0 left" do
  #               wikirate_layout_link
  #             end
  #           end
  #           html wikirate_tabs(tabs, type, extra)
  #         end
  #         html field_nest("right sidebar")
  #       end
  #     end
  #   end
  # end#

  def wikirate_layout_link
    link_text = wrap_with :div, class: "row-data center-logo" do
      field_nest "image"
    end
    link_to_card card.name.trunk, link_text, class: "inherit-anchor"
  end

  def wikirate_tabs tabs, color, additional=nil
    <<-HTML
      <div class="tabbable company-tabs">
        #{additional}
        <div class="col-md-8">
          <h2>
            <span class="#{color}-color">#{safe_name}</span>
          </h2>
        </div>
        #{tab_list tabs}
        <div class="tab-content">
          #{_render_tab_content}
				</div>
      </div>
    HTML
  end

  view :tab_content do
    tab_content
  end

  def tab_content
    # show the content based on the url parameter
    # tabs: metric, topic, company, note, reference, overview
    return "" unless (content_card = Card.fetch tab_card_name)
    subformat(content_card).render_content
  end

  def tab_card_name
    tab = Env.params["tab"]
    prefix = tab.nil? ? "metric" : tab
    "#{card.name.left}+#{prefix}_page"
  end
end
