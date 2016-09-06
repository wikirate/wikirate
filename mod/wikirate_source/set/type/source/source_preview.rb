include_set Abstract::Pdfjs

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

  def claim_count
    Card.search related_claim_wql
  end

  def metric_count
    Card.search related_metric_wql
  end

  view :preview, tags: :unknown_ok do |args|
    url_card = card.fetch(trait: :wikirate_link)
    url = url_card ? url_card.item_names.first : nil
    args[:url] = url
    wrap args do
      [
        # render in structure source_preview_nav_bar_structure
        render_navigation_bar(args),
        render_hidden_information(args),
        render_source_preview_container(args)
      ]
    end
  end

  view :source_preview_container, tags: :unknown_ok do |args|
    %(
      <div class="row clearfix source-preview-content">
        <div class="col-md-6 hidden-xs column source-iframe-container">
          #{render_iframe_view(args)}
        </div>
        <div class="col-md-6 column source-right-sidebar">
          #{render_tab_containers(args)}
        </div>
     </div>
    )
  end

  view :tab_containers, tags: :unknown_ok  do |_args|
    source_structure_args = { structure: "source_structure", show: "header" }
    loading_gif_html = Card["loading gif"].format.render_core
    %(
    <div class="tab-content">
      <span class="close-tab fa fa-times"></span>
      <div class="tab-pane active" id="tab_details">
        #{card.format.render_core source_structure_args}
      </div>
      <div class="tab-pane" id="tab_claims">
        #{loading_gif_html}
      </div>
      <div class="tab-pane" id="tab_metrics">
        #{loading_gif_html}
      </div>
      <div class="tab-pane" id="tab_view_original"></div>
    </div>
    )
  end

  view :iframe_view, tags: :unknown_ok  do |args|
    case card.source_type_codename
    when :text
      text_args = args.merge home_view: "open", hide: "toggle",
                             title: "Text Source"
      text_card = card.fetch trait: :text
      %(
        <div class="container-fluid">
          <div class="row-fluid">
            #{content_tag(:div, subformat(text_card).render(:open, text_args),
                          { id: 'text_source', class: 'webpage-preview' },
                          false)}
          </div>
        </div>
      )
    when :file
      file_card = card.fetch trait: :file
      if (mime = file_card.file.content_type) && valid_mime_type?(mime)
        if mime == "application/pdf"
          iframe_html = _render_pdfjs_iframe pdf_url: file_card.attachment.url
          content_tag(:div, iframe_html,
                      { id: "pdf-preview", class: "webpage-preview" },
                      false)
        else
          content_tag(:div,
                      %(<img id="source-preview-iframe"
                        src="#{file_card.attachment.url}" />),
                      { id: "pdf-preview", class: "webpage-preview" }, false)
        end
      else
        structure = "source item preview"
        redirect_content = _render_content args.merge(structure: structure)
        content_tag(:div, content_tag(:div, redirect_content,
                                      { class: "redirect-notice" }, false),
                    { id: "source-preview-iframe",
                      class: "webpage-preview non-previewable" },
                    false)
      end
    when :wikirate_link
      url = args[:url]
      iframe_html = %(
        <iframe id="source-preview-iframe" src="#{url}" security="restricted"
         sandbox="allow-same-origin allow-scripts allow-forms" ></iframe>
      )
      content_tag(:div, iframe_html,
                  { id: "webpage-preview", class: "webpage-preview" }, false)

    end
  end

  def valid_mime_type? mime_type
    mime_type == "application/pdf" || mime_type.start_with?("image/")
  end

  view :hidden_information, tags: :unknown_ok do |args|
    %(
      <div style="display:none">
        #{content_tag(:div, card.cardname.url_key, id: 'source-name')}
        #{content_tag(:div, args[:url], id: 'source_url')}
        #{content_tag(:div, args[:url], id: 'source-year')}
        #{content_tag(:div, args[:company], id: 'source_company')}
        #{content_tag(:div, args[:topic], id: 'source_topic')}
      </div>
    )
  end

  # View: HTML for the navigation bar on preview page
  view :navigation_bar, tags: :unknown_ok  do |args|
    %(
      <nav class="navbar navbar-default  ">

        <div class="">
          <!-- Brand and toggle get grouped for better mobile display -->
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <div id="source-preview-tabs" class="navbar-brand" href="#">
              #{web_link('/',
                         text: raw(nest(Card['*logo'],
                                        view: :core, size: :original)))}
            </div>
          </div>



          <!-- Collect the nav links, forms, and other content for toggling -->
          <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
            <!-- Navbar Menu -->
            #{subformat(Card['nav_bar_menu']).render_content}
            <ul class="nav nav-tabs navbar-right gray-color ">
               #{render_preview_options(args)}
            </ul>
          </div>
          <!-- /.navbar-collapse -->
        </div>
        <!-- /.container-fluid -->
      </nav>

    )
  end

  view :non_previewable, tags: :unknown_ok do |_args|
    if file_card = Card[card.name + "+File"]
      <<-HTML
        <a href="#{file_card.attachment.url}" class="btn btn-primary" role="button">Download</a>
      HTML
    else
      url_card = card.fetch(trait: :wikirate_link)
      url = url_card ? url_card.item_names.first : nil
      <<-HTML
        <a href="#{url}" class="btn btn-primary" role="button">Visit Original Source</a>)
      HTML
    end
  end

  def source_details_html
    <<-HTML
      <li role="presentation" class="active" >
        <a class='' data-target="#tab_details" data-toggle="source_preview_tab_ajax">
          <i class="fa fa-info-circle"></i> <span>Source Details</span>
        </a>
      </li>
    HTML
  end

  def claim_tab_html
    <<-HTML
      <li role="presentation" >
        <a class='' data-target="#tab_claims" data-toggle="source_preview_tab_ajax"  href='/#{card.cardname.url_key}+source_note_list?slot[hide]=header,menu' >
            <i class='fa fa-quote-left'><span id="claim-count-number " class="count-number">#{claim_count}</span></i><span>#{Card[ClaimID].name.pluralize}</span>
        </a>
      </li>
    HTML
  end

  def metric_tab_html
    <<-HTML
       <li role="presentation" >
        <a class='' data-target="#tab_metrics" data-toggle="source_preview_tab_ajax" href='/#{card.cardname.url_key}+metric_search?slot[hide]=header,menu' >
          <i class="fa fa-bar-chart">
          <span id="metric-count-number" class="count-number">
            #{metric_count}
          </span>
          </i>
          <span>#{Card[MetricID].name.pluralize}</span>
        </a>
      </li>
    HTML
  end

  def link_button url
    <<-HTML
      <li role="presentation" >
        <a class='' href='#{url}' target="_blank">
          <i class="fa fa-external-link-square"></i> Visit Original
        </a>
      </li>
    HTML
  end

  def file_download_button
    file_card = card.fetch trait: :file
    <<-HTML
      <li role="presentation" >
        <a class='' href='#{file_card.attachment.url}' download>
          <i class="fa fa-download" aria-hidden="true"></i> Download
        </a>
      </li>
    HTML
  end

  view :preview_options, tags: :unknown_ok  do |args|
    url = args[:url]
    result = source_details_html
    result += claim_tab_html
    result += metric_tab_html
    result +=
      case card.source_type_codename
      when :wikirate_link
        link_button url
      when :file
        file_download_button
      else
        ""
      end
    result
  end
end
