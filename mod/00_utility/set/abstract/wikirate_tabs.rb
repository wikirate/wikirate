format :html do
  def list_entry name, label, count_card_name
    count = Card.fetch(count_card_name, new: {})._render_core
    <<-HTML
        <a href="/{{_|linkname}}?tab=#{name}" data-tab-content-url="/{{_|linkname}}+#{name}_page" data-tab-name='#{name}' >
          <span class="count-number clearfix">#{count}</span>
           <span class="count-label">#{label}</span>
    </a>
    HTML
  end

  def tab_list tabs
    tabs.map do |args|
      list_entry *args
    end
    lis += [<<-HTML, class: "hidden-md hidden-lg"]
      <a href="#company-about" >
        <span class="count-number clearfix">&nbsp;</span>
        <span class="count-label">About</span>
      </a>
    HTML
    list_tag lis, class: "nav nav-tabs with-item-count text-center"
  end

  def wikirate_layout type, tabs, extra=nil
    <<-HTML
      <div class="container-fluid yinyang nodblclick">
        <div class="row">
          <div class="col-md-6 border-right">
            <div class="row clearfix #{type}-content #{type}-page-logo-container">
              <div class="col-md-12 col-xs-12 nopadding left">
                <a class="inherit-anchor" href="{{_l|url}}">
                  <div class="row-data center-logo ">
                    #{field_nest "image"}
                  </div>
                </a>
              </div>
            </div>
              #{wikirate_tabs tabs, type, extra}
            </div>
          </div>
            #{field_nest "right sidebar"}
          </div>
      </div>
    HTML
  end

  def wikirate_tabs tabs, color, additional=nil
  <<-HTML
      <div class="tabbable company-tabs">
        #{additional}
        <div class="col-md-8">
          <h2>
            <span class="#{color}-color">{{_|name}}</span>
          </h2>
        </div>
        #{tab_list tabs}
        <div class="tab-content">
          {{_|tab_content}}
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