format do
  include Type::SearchType::Format
  
  def search_results
    @search_results ||= 
        begin
          if !Auth.signed_in?
            searched_type_id = Card.fetch(card.cardname.parts[1]).id
            if Env.session[vote_type]
              Env.session[vote_type].map do |votee_id|
                if (votee = Card.find(votee_id)) && votee.type_id == searched_type_id
                  Card.fetch "#{votee.name}+card.cardname.parts[0]"
                end
              end.compact
            else
              []
            end
          else
            vote_trait = case vote_type
                         when :up_vote   then 'upvotes'
                         when :down_vote then 'downvotes'
                         end       
            if vote_trait && (vote_card = Auth.current.fetch(:trait=>vote_trait))
              votee_items = vote_card.item_names
              # super returns array with votee+company cards
              # in the topic case these cards are virtual so we can't use left_id
              # we have to fetch left to get the id
              super.sort do |x,y|
                votee_items.index("~#{x.left.id}") <=> votee_items.index("~#{y.left.id}")
              end
            else
              super
            end
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