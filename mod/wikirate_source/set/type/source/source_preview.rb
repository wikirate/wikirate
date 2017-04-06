include_set Abstract::Pdfjs
include_set Abstract::Tabs

format :html do
  def related_claim_wql
    {
      left: {
        type_id: Card::ClaimID
      },
      right: "source",
      link_to: card.name,
      return: "count"
    }
  end

  def related_metric_wql
    {
      type_id: Card::MetricID,
      right_plus: [
        { type_id: Card::WikirateCompanyID },
        right_plus: [
          { type: "year" },
          right_plus: [
            "source", { link_to: card.name }
          ]
        ]
      ],
      return: "count"
    }
  end

  def note_count
    Card.search related_claim_wql
  end

  def metric_count
    Card.search related_metric_wql
  end

  view :preview, tags: :unknown_ok do
    wrap do
      [
        # render in structure source_preview_nav_bar_structure
        # render_navigation_bar,
        render_hidden_information,
        render_source_preview_container
      ]
    end
  end

  def preview_url
    if @preview_url_loaded
      @preview_url
    else
      url_card = card.fetch(trait: :wikirate_link)
      @preview_url = url_card ? url_card.item_names.first : nil
    end
  end

  view :source_preview_container, tags: :unknown_ok do
    wrap_with :div, class: "row clearfix source-preview-content" do
      [
        wrap_with(:div, class: "col-md-6 hidden-xs column " \
                               "source-iframe-container") do
          render_iframe_view
        end,
        wrap_with(:div, class: "col-md-6 column source-right-sidebar") do
          render_tab_containers
        end
      ]
    end
  end

  view :tab_containers, tags: :unknown_ok do
    # loading_gif_html = Card["loading gif"].format.render_core
    _render_tabs
  end

  view :iframe_view, tags: :unknown_ok, cache: :never do
    send "#{card.source_type_codename}_iframe_view"
  end

  def file_iframe_view
    file_card = card.fetch trait: :file
    mime = file_card.file.content_type
    return nonpreviewable_iframe_view unless mime && valid_mime_type?(mime)
    method_prefix = mime == "application/pdf" ? :pdf : :standard_file
    send "#{method_prefix}_iframe_view", file_card
  end

  def nonpreviewable_iframe_view
    wrap_with :div, id: "source-preview-iframe",
                    class: "webpage-preview non-previewable" do
      wrap_with :div, class: "redirect-notice" do
        _render_content structure: "source item preview"
      end
    end
  end

  def standard_file_iframe_view file_card
    wrap_with :div, id: "pdf-preview", class: "webpage-preview" do
      wrap_with :img, "", id: "source-preview-iframe",
                          src: file_card.attachment.url
    end
  end

  def pdf_iframe_view file_card
    wrap_with :div, id: "pdf-preview", class: "webpage-preview" do
      _render_pdfjs_iframe pdf_url: file_card.attachment.url
    end
  end

  def wikirate_link_iframe_view
    wrap_with :div, id: "webpage-preview", class: "webpage-preview" do
      wrap_with :iframe, "",
                id: "source-preview-iframe", src: preview_url,
                sandbox: "allow-same-origin allow-scripts allow-forms",
                security: "restricted"
    end
  end

  def text_iframe_view
    wrap_with :div, class: "container-fluid" do
      wrap_with :div, class: "row-fluid" do
        wrap_with :div, id: "text_source", class: "webpage-preview" do
          text_card = card.fetch trait: :text
          nest text_card, view: "open", hide: "toggle", title: "Text Source"
        end
      end
    end
  end

  def valid_mime_type? mime_type
    mime_type == "application/pdf" || mime_type.start_with?("image/")
  end

  view :hidden_information, tags: :unknown_ok do |args|
    %(
      <div style="display:none">
        #{wrap_with(:div, card.cardname.url_key, id: 'source-name')}
        #{wrap_with(:div, preview_url, id: 'source_url')}
        #{wrap_with(:div, args[:year], id: 'source-year')}
        #{wrap_with(:div, args[:company], id: 'source_company')}
        #{wrap_with(:div, args[:topic], id: 'source_topic')}
      </div>
    )
  end

  # View: HTML for the navigation bar on preview page
  # view :navigation_bar, tags: :unknown_ok  do |args|
  #   %(
  #     <ul class="nav nav-tabs">
  #        #{render_preview_options(args)}
  #     </ul>
  #   )
  # end
  # view :navigation_bar, tags: :unknown_ok  do |args|
  #   navbar_brand = nest(Card[:logo], view: :core, size: :original)
  #   %(
  #     <nav class="navbar navbar-default  ">
  #
  #       <div class="">
  #         <!-- Brand and toggle get grouped for better mobile display -->
  #         <div class="navbar-header">
  #           <button type="button" class="navbar-toggle collapsed"
  #                   data-toggle="collapse"
  #                   data-target="#bs-example-navbar-collapse-1">
  #             <span class="sr-only">Toggle navigation</span>
  #             <span class="icon-bar"></span>
  #             <span class="icon-bar"></span>
  #             <span class="icon-bar"></span>
  #           </button>
  #           <div id="source-preview-tabs" class="navbar-brand" href="#">
  #             #{link_to_resource '/', raw(navbar_brand)}
  #           </div>
  #         </div>
  #
  #
  #
  #         <!-- Collect the nav links, forms, and other content for toggling -->
  #         <div class="collapse navbar-collapse"
  #              id="bs-example-navbar-collapse-1">
  #           <!-- Navbar Menu -->
  #           #{subformat(Card['nav_bar_menu']).render_content}
  #           <ul class="nav nav-tabs navbar-right gray-color ">
  #              #{render_preview_options(args)}
  #           </ul>
  #         </div>
  #         <!-- /.navbar-collapse -->
  #       </div>
  #       <!-- /.container-fluid -->
  #     </nav>
  #
  #   )
  # end

  view :non_previewable, tags: :unknown_ok do |_args|
    if file_card = Card[card.name + "+File"]
      <<-HTML
        <a href="#{file_card.attachment.url}" class="btn btn-primary" role="button">Download</a>
      HTML
    else
      url_card = card.fetch(trait: :wikirate_link)
      url = url_card ? url_card.item_names.first : nil
      <<-HTML
        <a href="#{preview_url}" class="btn btn-primary" role="button">Visit Original Source</a>
      HTML
    end
  end

  # def source_details_html
  #   <<-HTML
  #     <li role="presentation" class="active" >
  #       <a class='' data-target="#tab_details" data-toggle="source_preview_tab_ajax">
  #         <i class="fa fa-info-circle"></i> <span>Source Details</span>
  #       </a>
  #     </li>
  #   HTML
  # end
  #
  # def claim_tab_html
  #   <<-HTML
  #     <li role="presentation" >
  #       <a class='' data-target="#tab_claims" data-toggle="source_preview_tab_ajax"  href='/#{card.cardname.url_key}+source_note_list?slot[hide]=header,menu' >
  #           <i class='fa fa-quote-left'><span id="claim-count-number " class="count-number">#{note_count}</span></i><span>#{Card[ClaimID].name.pluralize}</span>
  #       </a>
  #     </li>
  #   HTML
  # end
  #
  # def metric_tab_html
  #   <<-HTML
  #      <li role="presentation" >
  #       <a class='' data-target="#tab_metrics" data-toggle="source_preview_tab_ajax" href='/#{card.cardname.url_key}+metric_search?slot[hide]=header,menu' >
  #         <i class="fa fa-bar-chart">
  #         <span id="metric-count-number" class="count-number">
  #           #{metric_count}
  #         </span>
  #         </i>
  #         <span>#{Card[MetricID].name.pluralize}</span>
  #       </a>
  #     </li>
  #   HTML
  # end
  #
  # def link_button url
  #   <<-HTML
  #     <li role="presentation" >
  #       <a class='' href='#{url}' target="_blank">
  #         <i class="fa fa-external-link-square"></i> Visit Original
  #       </a>
  #     </li>
  #   HTML
  # end
  #
  # def file_download_button
  #   file_card = card.fetch trait: :file
  #   <<-HTML
  #     <li role="presentation" >
  #       <a class='' href='#{file_card.attachment.url}' download>
  #         <i class="fa fa-download" aria-hidden="true"></i> Download
  #       </a>
  #     </li>
  #   HTML
  # end
  #
  # view :preview_options, tags: :unknown_ok do
  #   url = preview_url
  #   result = source_details_html
  #   result += claim_tab_html
  #   result += metric_tab_html
  #   result +=
  #     case card.source_type_codename
  #     when :wikirate_link
  #       link_button url
  #     when :file
  #       file_download_button
  #     else
  #       ""
  #     end
  #   result
  # end
end
