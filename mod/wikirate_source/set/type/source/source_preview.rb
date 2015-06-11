format :html do

  view :preview ,:tags=>:unknown_ok do |args|
    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    url = Card::Env.params[:url]

    from_certh = !card.real?

    if card.real?
      company_card = card.fetch(:trait=>:wikirate_company)
      topic_card = card.fetch(:trait=>:wikirate_topic)
      url_card = card.fetch(:trait=>:wikirate_link)
      company = company_card ? company_card.item_names.first : nil
      topic = topic_card ? topic_card.item_names.first : nil
      url = url_card ? url_card.item_names.first : nil
    end

    args.merge!({:url=>url,:company=>company, :topic=>topic})
    if from_certh
      source = Self::Source.find_duplicates url
      if source.any? and source_card = source.first.left and company_and_topic_match? company,topic, url, source_card.name
        return subformat( source_card ).render_preview args
      end
    end
    wrap args do
    [
      render_navigation_bar(args),#render in structure source_preview_nav_bar_structure
      render_hidden_information(args),
      render_source_preview_container(args)
    ]
    end
  end

  view :source_preview_container,:tags=>:unknown_ok  do |args|
    %{
      <div class="row clearfix source-preview-content">
        <div class="col-md-6 hidden-xs column source-iframe-container">
          #{render_iframe_view(args)}
        </div>
        <div class="col-md-6 column source-righ-sidebar">
          #{render_tab_containers(args)}
        </div>
     </div>
    }
  end


  view :hidden_information, :tags=>:unknown_ok do |args|
    %{  
      <div style="display:none">
        #{content_tag(:div, card.cardname.url_key, {:id=>"source-name"})}
        #{content_tag(:div, args[:url], {:id=>"source_url"})}
        #{content_tag(:div, args[:company], {:id=>"source_company"})}
        #{content_tag(:div, args[:topic], {:id=>"source_topic"})}
      </div>
    }
  end

  #View: HTML for the navigation bar on preview page
  view :navigation_bar ,:tags=>:unknown_ok  do |args|
    %{
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
              #{web_link("/", :text=>raw( nest Card["*logo"], :view=>:core, :size=>:original ))}
            </div>
          </div>

          <!-- Collect the nav links, forms, and other content for toggling -->
          <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
            <ul class="nav nav-tabs navbar-right gray-color ">
               #{render_preview_options(args)}
            </ul>
          </div>
          <!-- /.navbar-collapse -->
        </div>
        <!-- /.container-fluid -->
      </nav>

    }
  end


  view :non_previewable ,:tags=>:unknown_ok do |args|
    if file_card = Card[card.name+"+File"]
      %{<a href="#{file_card.attach.url}" class="btn btn-primary" role="button">Download</a>}
    else
      url = if card.real?
        url_card = card.fetch(:trait=>:wikirate_link)
        url_card ? url_card.item_names.first : nil
      else
        Card::Env.params[:url]
      end
      %{<a href="#{url}" class="btn btn-primary" role="button">Visit Source</a>}
    end
  end

  view :preview_options, :tags=>:unknown_ok  do |args|
    from_certh = !card.real?
    url = args[:url]
    if !url
       if card.real?
        url_card = card.fetch(:trait=>:wikirate_link)
        url = url_card ? url_card.item_names.first : nil
      end
    end
    %{
        #{show_options from_certh, card.cardname.url_key ,url}
    }
  end
  
  view :iframe_view ,:tags=>:unknown_ok  do |args|
    url = args[:url]
    file_card = Card[card.name+"+File"]
    text_card = Card[card.name+"+Text"]
    if text_card
      ##{content_tag(:div, nest(text_card,:view=>"open",:hide=>"toggle"), {:id=>"text_source", :class=> "webpage-preview "},false) }
      %{
        <div class="container-fluid">
          <div class="row-fluid">
            #{content_tag(:div, subformat(text_card).render(:open,args.merge({:home_view=>"open",:hide=>"toggle",:title=>"Text Source"})), {:id=>"text_source", :class=> "webpage-preview "},false) }
          </div>
        </div>
      }
      #col-md-12 column

    elsif file_card
      if mime_type = file_card.content.split("\n")[1] and ( mime_type == "application/pdf" or mime_type.start_with?("image/") )
        if mime_type == "application/pdf"
          content_tag(:div, '<iframe id="source-preview-iframe" src="pdfjs/viewer.html?file='+ file_card.attach.url+'"  security="restricted" sandbox="allow-same-origin allow-scripts allow-forms" ></iframe>', {:id=>"pdf-preview", :class=> "webpage-preview"},false)
        else
          content_tag(:div, '<img id="source-preview-iframe" src="'+file_card.attach.url+'"  / >', {:id=>"pdf-preview", :class=> "webpage-preview"},false)
        end
      else
        redirect_content = _render_content args.merge({:structure=>"source item preview"})
        content_tag(:div, content_tag(:div, redirect_content,{:class=> "redirect-notice"},false),  {:id=>"source-preview-iframe", :class=> "webpage-preview non-previewable"},false)
      end
    else
      content_tag(:div, '<iframe id="source-preview-iframe" src="' + URI.escape(url) + '"  security="restricted" sandbox="allow-same-origin allow-scripts allow-forms" ></iframe>', {:id=>"webpage-preview", :class=> "webpage-preview"},false)
    end
  end

 

  def show_options source_from_certh,source_page_name,url
    if source_from_certh
      %{
        <li>
          <a href="#" id="mark-relevant-button" class="button-primary">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Relevant</span>
          </a>
        </li>
        <li>
          <a href="#" id="mark-irrelevant-button" class="button-primary button-secondary">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Irrelevant</span>
          </a>
        </li>
      }
    else

      related_claim_wql = {:left=>{:type=>"Claim"},:right=>"source",:link_to=>"#{source_page_name}",:return=>"count"}
      related_metric_wql = {:type=>"metric", :right_plus=>[{"type"=>"company"}, :right_plus=>[{:type=>"year"}, :right_plus=>["source", {:link_to=>source_page_name}]]],:return=>"count"}
      claim_count = Card.search related_claim_wql
      metric_count = Card.search related_metric_wql
      file_card = Card[card.name+"+File"]
      text_card = Card[card.name+"+Text"]


      #Source Details tab
      result = %{
        <li role="presentation" class="active" >
          <a class='' data-target="#tab_details" data-toggle="source_preview_tab_ajax">
            <i class="fa fa-info-circle"></i> <span>Details</span>
          </a>
        </li>
      }

      #Claims tab
      result += %{
        <li role="presentation" >
          <a class='' data-target="#tab_claims" data-toggle="source_preview_tab_ajax"  href='/#{source_page_name}+source_claim_list?slot[hide]=header,menu' >
              <i class='fa fa-quote-left'><span id="claim-count-number " class="count-number">#{claim_count}</span></i><span>Claims</span>
          </a>
        </li>
      }

      #Metrics tab
      result += %{
        <li role="presentation" >
          <a class='' data-target="#tab_metrics" data-toggle="source_preview_tab_ajax" href='/#{source_page_name}+metric_search?slot[hide]=header, menu' >
            <i class="fa fa-glass"><span id="claim-count-number " class="count-number">#{metric_count}</span></i><span>Metrics</span>
          </a>
        </li>
      }

      #External Link
      if !( file_card || text_card )
        result += %{
          <li role="presentation" >
            <a class='' href='#{url}' >
              <i class="fa fa-external-link-square"></i> View Original
            </a>
          </li>
        }
      end

      result
    end
  end

  view :tab_containers, :tags=>:unknown_ok  do |args|
    %{
    <div class="tab-content">
      <div class="tab-pane active" id="tab_details">#{card.format.render_core ({:structure=>"source_structure",:show=>"header"})}</div>
      <div class="tab-pane" id="tab_claims">#{Card["loading gif"].format.render_core } </div>
      <div class="tab-pane" id="tab_metrics">#{Card["loading gif"].format.render_core} </div>
      <div class="tab-pane" id="tab_view_original"></div>
    </div>
    }

  end
end
