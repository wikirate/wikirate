format do
  include Type::SearchType::Format
  
  def search_results
    @search_results ||= 
        begin
          if !Auth.signed_in?
            searched_type_id = Card.fetch(card.cardname.parts[1]).id
            if Env.session[vote_type]
              Env.session[vote_type].select do |votee_name|
                (votee = Card.fetch(votee_name)) && votee.type_id == searched_type_id
              end.map do |votee_name|
                "#{votee_name}+card.cardname.parts[0]"
              end
            else
              []
            end
          else
            super
          end
        end
  end
  
  def vote_type
    case card.cardname.left_name.right
    when '*upvotes'
      :up_vote
    when '*downvotes'
      :down_vote
    else
      :no_vote
    end
  end
  
end

format :html do
  include Right::NonVoteeSearch::HtmlFormat
  
  def default_drag_and_drop_args args
    super(args)
    if !Card::Auth.signed_in? 
      args[:unsaved] = 
        if ( unsaved = Card.fetch("#{card.cardname.parts[-2]}+#{Card[:unsaved_list].name}") )
          subformat(unsaved).render_core(args)
        else
          subformat(Card[:unsaved_list]).render_core(args)
        end
    end
    if ( empty = Card.fetch("#{card.cardname.parts[-2]}+#{Card[:empty_list].name}") )
      args[:empty] = subformat(empty).render_core(args)
    end

    args[:vote_type] = vote_type      
    args[:query] = 'vote=' +
                   case args[:vote_type]
                   when :up_vote   then 'force-up'
                   when :down_vote then 'force-down'
                   when :no_vote   then 'force-neutral'
                   end
  end
end