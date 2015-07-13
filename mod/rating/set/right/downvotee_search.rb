def virtual?; true end

def raw_content
  %({"type":"_r","linked_to_by":{"left":"_user","right":{"codename":"#{vote_type_codename}"}}, "limit":0})
end

def vote_type
  :down_vote
end

def vote_type_codename
  :downvotes
end

def vote_label
  # should be card content
  'Not Important to Me'
end

def sort_by
  vote_type_codename
end



format do
  include Type::SearchType::Format

  alias :super_search_results :search_results

  def search_results
    @search_results ||= enrich_result(get_search_result)
  end

  def get_search_result
    if !Auth.signed_in?
      get_result_from_session
    else
      if card.sort_by && (vote_card = Auth.current.fetch(:trait=>card.sort_by))
        votee_items = vote_card.item_names
        super_search_results.sort do |x,y|  # super returns array with votee cards
          votee_items.index("~#{x.id}") <=> votee_items.index("~#{y.id}")
        end
      else
        super_search_results
      end
    end
  end

  def get_result_from_session
    list_with_session_votes
  end

  def list_with_session_votes
    if Env.session[card.vote_type]
      Env.session[card.vote_type].map do |votee_id|
        Card.find_by_id_and_type_id votee_id, searched_type_id
      end.compact
    else
      []
    end
  end
end

format :html do
  view :drag_and_drop do |args|
    res = with_drag_and_drop(args) do
      search_results.map do |item|
        votee = extract_votee item
        draggable_opts = {
          :votee_id    => votee.id,
          :update_path => votee.vote_count_card.format.vote_path,
          :sort        => { :importance=>votee.vote_count }
        }
        case main_type_id
        when WikirateTopicID then topic_draggable_opts(votee,draggable_opts)
        when MetricID then metric_draggable_opts(votee, draggable_opts)
        when WikirateCompanyID then company_draggable_opts(votee, draggable_opts)
        when WikirateAnalysisID then analysis_draggable_opts(votee, draggable_opts)
        end
        draggable nest(item), draggable_opts
      end.join("\n").html_safe
    end.html_safe
  end

  view :filter_and_sort do |args|
    res = with_filter_and_sort(args) do
      search_results.map do |item|
        votee = extract_votee item
        sort_opts = { :sort => {} }
        case main_type_id
        when WikirateTopicID then topic_draggable_opts(votee,sort_opts)
        when MetricID then metric_draggable_opts(votee, sort_opts)
        when WikirateCompanyID then company_draggable_opts(votee, sort_opts)
        when WikirateAnalysisID then analysis_draggable_opts(votee, sort_opts)
        end

        sortable nest(item), sort_opts
      end.join("\n").html_safe
    end.html_safe
  end

  def default_drag_and_drop_args args
    args[:vote_type] ||= card.vote_type
    args[:query] ||= 'vote=force-down'
    args[:empty] ||=
      if ( empty =  Card[card.vote_type_codename].fetch(:trait=>:empty_list) || Card[:empty_list] )
        subformat(empty).render_core(args)
      else
        ''
      end
    if !Card::Auth.signed_in? &&
       ( unsaved = Card[card.vote_type_codename].fetch(:trait=>:unsaved_list) || Card[:unsaved_list] )
      args[:unsaved] ||= subformat(unsaved).render_core(args)
    end
  end

  def extract_votee item
    if main_type_id == WikirateAnalysisID
      item[2..-2]
    else
      item[1..-2]
    end
  end

  def metric_draggable_opts votee, opts
    case votee.type_id
    when WikirateCompanyID
      metric_plus_company = Card.fetch("#{main_name}+#{votee.name}")
      opts[:no_value] = metric_plus_company.new_card?
    end
  end

  def topic_draggable_opts votee, opts
    case votee.type_id
    when MetricID
      topic_tags = votee.fetch :trait=>:wikirate_topic
      opts[:no_value] = !topic_tags || !topic_tags.include_item?(main_name)
    when WikirateCompanyID
      if (analysis = Card.fetch "#{votee.name}+#{main_name}")
        claim_cnt = Card.fetch("#{analysis.name}+claim").cached_count
        source_cnt = Card.fetch("#{analysis.name}+sources").cached_count
        opts[:sort][:contributions] = analysis.direct_contribution_count.to_i + claim_cnt + source_cnt
        opts[:sort][:name] = votee.name.upcase
      end
    end
  end

  def analysis_draggable_opts votee, opts
    case votee.type_id
    when MetricID
      metric_plus_company = Card.fetch("#{votee.name}+#{main_name.to_name.left}")
      topic_tags = votee.fetch :trait=>:wikirate_topic
      opts[:no_value] = (metric_plus_company.new_card? || !topic_tags || !topic_tags.include_item?(main_name.to_name.right))
      opts[:sort][:recent] = metric_plus_company.updated_at.to_i
    end
  end

  def company_draggable_opts votee, opts
    case votee.type_id
    when WikirateTopicID
      opts[:sort][:recent] = votee.updated_at.to_i
      if (analysis = Card.fetch "#{main_name}+#{votee.name}")
        claim_cnt = Card.fetch("#{analysis.name}+claim").cached_count
        source_cnt = Card.fetch("#{analysis.name}+sources").cached_count
        opts[:sort][:contributions] = analysis.direct_contribution_count.to_i + claim_cnt + source_cnt
      end
    when MetricID
      metric_plus_company = Card.fetch("#{votee.name}+#{main_name}")
      opts[:no_value] = metric_plus_company.new_card?
      opts[:sort][:recent] = metric_plus_company.updated_at.to_i
    end
  end

  def with_filter_and_sort args
    display_empty_msg = search_results.empty? ? '' : 'display: none;'
    content_tag :div, :class=>"yinyang-list",
                      'data-default-sort'=>args[:default_sort] do
        yield
    end
  end

  def with_drag_and_drop args
    show_unsaved_msg = args[:unsaved].present? && !Auth.signed_in?
    content_tag :div, :class=>"list-drag-and-drop yinyang-list #{args[:vote_type]}-container",
                      'data-query'=>args[:query],
                      'data-update-id'=>card.cardname.url_key,
                      'data-bucket-name'=>args[:vote_type],
                      'data-default-sort'=>args[:default_sort] do
      [
        (content_tag(:h5, :class=>'vote-title') { card.vote_label } if card.vote_label),
        content_tag(:div,:class=>'empty-message') { args[:empty] },
        ((content_tag(:div,:class=>'alert alert-info unsaved-message') { args[:unsaved] } ) if show_unsaved_msg ),
        yield
      ].compact.join.html_safe
    end
  end

  def draggable content, args
    html_args = {
      'data-update-path' => args[:update_path],
      'data-votee-id'    => args[:votee_id],
      :class             => 'drag-item yinyang-row'
    }
    html_args[:class] += ' no-metric-value' if args[:no_value]
    args[:sort].each { |k,v| html_args["data-sort-#{k}"] = v } if args[:sort]

    content_tag :div, content.html_safe, html_args
  end

  def sortable content, args
    html_args = { :class => 'yinyang-row' }
    html_args[:class] += ' no-metric-value' if args[:no_value]
    args[:sort].each { |k,v| html_args["data-sort-#{k}"] = v } if args[:sort]
    content_tag :div, content.html_safe, html_args
  end

end