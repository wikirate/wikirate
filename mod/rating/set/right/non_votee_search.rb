
format do
  include Type::SearchType::Format
  
  def search_results
    @search_results ||= 
      begin
        result = super
        
        if !Auth.signed_in?
          #searched_type_id = Card.fetch(card.cardname.parts[1]).id
          [:up_vote, :down_vote].each do |bucket|    
            if Env.session[bucket]
              result.reject! do |votee_plus_company|
                votee_name = votee_plus_company.to_name.left
                (votee_id = Card.fetch_id(votee_name)) && Env.session[bucket].include?(votee_id)#type_id == searched_type_id
              end
            end
          end
        end
        
        result
      end
  end
end


format :html do
  def default_drag_and_drop_args args
    args[:unsaved] ||= ''
    args[:empty] ||=       
      if ( empty = Card[:empty_list] )
        subformat(empty).render_core(args)
      else
        ''
      end
    args[:query] ||= 'vote=force-neutral'
    args[:vote_type] ||= :no_vote
    args[:default_sort] ||=
      if card[1].id == WikirateTopicID
        :contributions
      else
        :importance
      end
  end
  
  view :drag_and_drop do |args|
    with_drag_and_drop(args) do
      search_results.map do |votee_plus_company| 
        votee = votee_plus_company.left
        draggable_opts = {
          :votee_id    => votee.id,
          :update_path => votee.vote_count_card.format.vote_path, 
          :sort        => {:importance=>votee.vote_count}
        }
        if votee.type_id == MetricID
          draggable_opts[:no_value] = votee_plus_company.new_card?
          draggable_opts[:sort][:recent] = votee_plus_company.updated_at.to_i
        else
          draggable_opts[:sort][:recent] = votee.updated_at.to_i
          if (analysis = Card.fetch "#{votee_plus_company.cardname.parts[1]}+#{votee_plus_company.cardname.parts[0]}")
            claim_cnt = subformat(Card.fetch("#{analysis.name}+claim+*count")).render_core.to_i
            source_cnt = subformat(Card.fetch("#{analysis.name}+sources+*count")).render_core.to_i
            draggable_opts[:sort][:contributions] = analysis.direct_contribution_count.to_i + claim_cnt + source_cnt
          end
        end

        draggable nest(votee_plus_company), draggable_opts
      end.join("\n").html_safe
    end.html_safe
  end
  
  def with_drag_and_drop args
    display_empty_msg = search_results.empty? ? '' : 'display: none;'
    content_tag :div, :class=>"list-drag-and-drop list-group", 
                      'data-query'=>args[:query], 
                      'data-update-id'=>card.cardname.url_key, 
                      'data-bucket-name'=>args[:vote_type],
                      'data-default-sort'=>args[:default_sort] do
      [
        content_tag(:div,:class=>'empty-message',:style=>display_empty_msg) { args[:empty] },
        content_tag(:div,:class=>'unsaved-message') { args[:unsaved] },
        yield
      ].join.html_safe
    end
  end
  
  def draggable content, args
    data_args = {
      'data-update-path' => args[:update_path],
      'data-votee-id'    => args[:votee_id],
      :class             => 'drag-item list-group-item'
    }
    data_args[:class] += ' no-metric-value' if args[:no_value]
    args[:sort].each { |k,v| data_args["data-sort-#{k}"] = v }
    
    content_tag :div, content.html_safe, data_args
  end
  
end
