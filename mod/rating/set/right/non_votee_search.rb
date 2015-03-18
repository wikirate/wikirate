
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
  end
  
  view :drag_and_drop do |args|        
    with_drag_and_drop(args) do
      search_results.map do |votee_plus_company| 
        votee = votee_plus_company.left
        updated_at = 
          if votee.type_id == Card::MetricID 
            votee_plus_company.updated_at.to_i
          else
            votee.updated_at.to_i
          end          

        draggable nest(votee_plus_company), :votee_id => votee.id,
                                            :update_path => votee.vote_count_card.format.vote_path, 
                                            :sort => {:importance=>votee.vote_count, :recent=>updated_at}
                                      
      end.join("\n").html_safe
    end.html_safe
  end
  
  def with_drag_and_drop args
    display_empty_msg = search_results.empty? ? '' : 'display: none;'
    content_tag :div, :class=>"list-drag-and-drop list-group", 
                      'data-query'=>args[:query], 
                      'data-update-id'=>card.cardname.url_key, 
                      'data-bucket-name'=>args[:vote_type] do
      [
        content_tag(:div,:class=>'empty-message',:style=>display_empty_msg) { args[:empty] },
        content_tag(:div,:class=>'unsaved-message') { args[:unsaved] },
        yield
      ].join.html_safe
    end
  end
  
  def draggable content, args
    data_args = {'data-update-path' => args[:update_path],
                 'data-votee-id' => args[:votee_id]        }
    args[:sort].each do |k,v|
      data_args["data-sort-#{k}"] = v
    end
    content_tag(:div,content.html_safe, data_args.merge(:class=>'drag-item list-group-item'))
  end
  
end
