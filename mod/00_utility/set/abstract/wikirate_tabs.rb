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
                   path(mark: [card.cardname, "#{name}_page"])
    # <<-HTML
    #   <a href="/{{_|linkname}}?tab=#{name}"
    #      data-tab-content-url="/{{_|linkname}}+#{name}_page"
    #      data-tab-name='#{name}' >
    #
    #   </a>
    # HTML
  end

  def tab_list tabs
    lis = tabs.map do |args|
      list_entry *args
    end
    # lis += [<<-HTML, class: "hidden-md hidden-lg"]
    #   <a href="#company-about" >
    #     <span class="count-number clearfix">&nbsp;</span>
    #     <span class="count-label">About</span>
    #   </a>
    # HTML
    list_tag lis, class: "nav nav-tabs with-item-count text-center"
  end

  def wikirate_layout type, tabs, extra=nil
    link_text = %(
    <div class="row-data center-logo ">
                    #{field_nest "image"}
                  </div>)
    layout container: true, fluid: true, class: "yinyang nodblclick" do
      row 6 do
        col class: "border-right" do
          row md: 12, xs: 12,
              class: "clearfix #{type}-content #{type}-page-logo-container" do
            col class: "nopadding left" do
              link_to_card card.cardname.trunk, link_text,
                           class: "inherit-anchor"
            end
          end
          add_html wikirate_tabs(tabs, type, extra)
        end
        add_html field_nest("right sidebar")
      end
    end
    # <<-HTML
    #   <div class="container-fluid ">
    #     <div class="row">
    #       <div class="col-md-6 border-right">
    #         <div class="row clearfix #{type}-content #{type}-page-logo-container ">
    #           <div class="col-md-12 col-xs-12 nopadding left">
    #             #{link_to_card card.left, link_text, class: "inherit-anchor"}
    #           </div>
    #         </div>
    #           #{wikirate_tabs tabs, type, extra}
    #         </div>
    #         #{field_nest "right sidebar"}
    #       </div>
    #      </div>
    #   </div>
    # HTML
  end

  def wikirate_tabs tabs, color, additional=nil
  <<-HTML
      <div class="tabbable company-tabs">
        #{additional}
        <div class="col-md-8">
          <h2>
            <span class="#{color}-color">#{card.name}</span>
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
    # show the content based on the url parameter
    # tabs: metric, topic, company, note, reference, overview
    tab = Env.params["tab"]
    left_name = card.cardname.left
    card_tab_name =
      if !tab.nil?
        "#{left_name}+#{tab}_page"
      else
        "#{left_name}+metric_page"
      end
    if (content_card = Card.fetch card_tab_name)
      subformat(content_card).render_content
    else
      ""
    end
  end
end