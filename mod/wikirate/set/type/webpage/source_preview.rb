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
      source = Self::Webpage.find_duplicates url
      if source.any? and source_card = source.first.left and company_and_topic_match? company,topic, url, source_card.name
        return subformat( source_card ).render_preview args
      end
    end
    wrap args do
    [
      render_hidden_information(args),
      render_logo_bar(args),
      render_iframe_view(args)
    ]
    end
  end
  view :hidden_information, :tags=>:unknown_ok do |args|
    %{  
      <div style="display:none">
        #{content_tag(:div, Auth.current_id, {:id=>"user-id"})}
        #{content_tag(:div, card.cardname.url_key, {:id=>"source-name"})}
        #{content_tag(:div, args[:url], {:id=>"source_url"})}
        #{content_tag(:div, args[:company], {:id=>"source_company"})}
        #{content_tag(:div, args[:topic], {:id=>"source_topic"})}
      </div>
    }
  end
  view :logo_bar ,:tags=>:unknown_ok  do |args|
    %{
      <div id="logo-bar" class="top-bar nodblclick">
        #{content_tag(:div, web_link("/", :text=>raw( nest Card["*logo"], :view=>:content, :size=>:medium )), {:class=> "top-bar-icon"},false)}
        #{render_preview_options(args)}
        #{render_company_and_topic_detail(args)}
      </div>
    }
  end

  view :company_and_topic_detail, :tags=>:unknown_ok  do |args|
    company = args[:company]
    topic = args[:topic]
    #refresh from front end
    if !company or !topic
      if card.real?
        company_card = card.fetch(:trait=>:wikirate_company)
        topic_card = card.fetch(:trait=>:wikirate_topic)
        company = company_card ? company_card.item_names.first : nil
        topic = topic_card ? topic_card.item_names.first : nil
      end
    end

    dropdown_class = ""
    from_certh = !card.real? 
    
    dropdown_class = "no-dropdown"  if from_certh
    
    first_company = first_or_add company,"company",!from_certh
    first_topic = first_or_add topic,"topic",!from_certh
    
    %{
      <div id="company-and-topic" class="company-and-topic">
        #{first_company}
        #{first_topic}
        <a href="/#{card.name}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="#{dropdown_class}">
          <i class="fa fa-caret-square-o-down"></i>
        </a>
      </div>
    } 
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
       <div class="menu-options">
        #{show_options from_certh, card.name ,url}
      </div>
    }
  end

  view :iframe_view ,:tags=>:unknown_ok  do |args|
    url = args[:url]
    content_tag(:div, '<iframe id="source-preview-iframe" src="' + URI.escape(url) + '"  security="restricted" sandbox="allow-same-origin allow-scripts allow-forms" >', {:id=>"webpage-preview", :class=> "webpage-preview"},false)
  end

  def company_and_topic_match? company, topic , url, source_name
    source = Self::Webpage.find_duplicates url
    return false if ! source.any?
    source_name = source.first.left.name 
    company_pointer = Card[source_name].fetch :trait=>:wikirate_company
    topic_pointer = Card[source_name].fetch :trait=>:wikirate_topic
    if company_pointer and topic_pointer
      if company_pointer.item_names.include?(company) and topic_pointer.item_names.include?(topic)
        return true 
      end
    end
    false
  end
  def first_or_add first_name, type_name, show_add_link
    no_content_class = "no-content"
    content = if first_name
      linkname = first_name
      linkname = Card[first_name].cardname.url_key if Card[first_name]
      no_content_class = ""
      %{
        <a href="#{linkname}" target="_blank">
          <span class="#{type_name}-name">#{first_name}</span>
        </a>
      }  
    else
      if show_add_link
        %{<a id='add-#{type_name}-link' href='#' >Add #{type_name.humanize}</a>}
      else
        no_content_class=""
        ""
      end
    end
    %{
      <div class="#{type_name}-name #{no_content_class}">
        #{content}
      </div>
    }
  end

  def show_options source_from_certh,source_page_name,url
    if source_from_certh
      %{
        <div id="mark-irrelevant" >
          <a href="#" id="mark-irrelevant-button" class="button-primary button-secondary">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Irrelevant</span>
          </a>
        </div>
        <div id="mark-relevant" >
          <a href="#" id="mark-relevant-button" class="button-primary">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Relevant</span>
          </a>
        </div>
      }
    else
      
      related_claim_wql = {:left=>{:type=>"Claim"},:right=>"source",:link_to=>"#{source_page_name}",:return=>"count"}
      claim_count = Card.search related_claim_wql

      result = %{
        <div id="source-page-link" class="mark-irrelevant-button" >
          <a href="/#{source_page_name}?layout=wikirate layout" id="source-page-button" target="_blank">
            Source Details
            <i class="fa fa-chevron-circle-right"></i>
          </a>
          <a href="#{url}" id="direct-link-button" target="_blank">
            Direct Link
            <i class="fa fa-chevron-circle-right"></i>
          </a>
        </div>
        <div id="make-claim" class="button-primary">
          <a href="#" id="make-a-claim-button">
            <span>Make a Claim</span>
          </a>
        </div>
      }
      result+=%{
        <div id="claim-count">
        #{
        "<a class='show-link-in-popup' href='/#{source_page_name}+source claim list' target='_blank'>
          <span class='claim-count'>
            #{claim_count}
          </span>
          <span class='claim-count'>Claims</span>
        </a>" if claim_count != 0}
        </div>} 
      result
    end
  end

end