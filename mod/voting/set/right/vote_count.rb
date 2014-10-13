
def vote_up
  case vote_status
  when '?'
    uv_card = Auth.current.upvotes_card
    if uv_card.add_id left.id
      uv_card.save!
      add_upvote
      #self.content = (content.to_i + 1).to_s
    end
  when '-'
    dv_card = Auth.current.downvotes_card
    if dv_card.drop_id left.id
      dv_card.save!
      delete_downvote
      #self.content = (content.to_i + 1).to_s
    end
  end

end

def vote_down
  case vote_status
  when '?'
    dv_card = Auth.current.downvotes_card
    if dv_card.add_id left.id
      dv_card.save!
      add_downvote
    end
  when '+'
    uv_card = Auth.current.upvotes_card
    if uv_card.drop_id left.id
      uv_card.save!
      delete_upvote
    end
  end
end

def add_upvote;      update_votecount :upvote,   1; end
def delete_upvote;   update_votecount :upvote,  -1; end
def add_downvote;    update_votecount :downvote, 1; end
def delete_downvote; update_votecount :downvote,-1; end

def update_votecount type, value
  Auth.as_bot do
    case type
    when :upvote
      subcards[left.upvote_count_card.name] = (left.upvote_count.to_i + value).to_s
      self.content = (content.to_i + value).to_s
    when :downvote
      subcards[left.downvote_count_card.name] = (left.downvote_count.to_i + value).to_s
      self.content = (content.to_i - value).to_s
    end
  end
end


event :vote, :before=>:approve, :on=>:update, :when=>proc{ |c| Env.params['vote'] } do
  if Auth.signed_in?
    case Env.params['vote']
    when 'up' then vote_up
    when 'down' then vote_down
    end
  else
   Env.params[:success] = "REDIRECT: #{Card[:signin].cardname.url_key}"
   path_hash = {:card=>self, :action=>:update, 
                 :success=>{:id=>left.name}, :vote=>Env.params['vote'] }
   format = self.format
   format.save_interrupted_action path_hash
   abort :success 
  end
end


def vote_status
  if Auth.signed_in?
    if Auth.current.upvotes_card.include_item? "~#{left.id}"
      '+'
    elsif Auth.current.downvotes_card.include_item? "~#{left.id}"
      '-'
    else
      '?'
    end
  else
    '#'
  end
end


format :html do  
  
  def no_link up_or_down, message
    "<i class=\"fa fa-chevron-#{up_or_down}\"></i>"
  end

  def vote_link text, title, up_or_down, add_or_drop, extra={}
    #votes_card = up_or_down == :up ? Auth.current.upvotes_card : Auth.current.downvotes_card
    votes_card = card
    path_hash = {:card=>votes_card, :action=>:update, :view=>:core} #, 
#                 :success=>{:id=>card.name, :view=>:core} }
    #path_hash["#{add_or_drop}_item".to_sym] = card.left.name
    path_hash[:vote] = up_or_down
    
    link_to path(path_hash), 
        {:class=>"slotter", :title=>title, :remote=>true, :method=>'post',  :slotSelector=>".vote"}.merge(extra) do
      text
    end
  end


  def vote_up_link
    case card.vote_status
    when '+'
      no_link :up, "You have already upvoted this claim."
    else
      vote_link '<i class="fa fa-chevron-up"></i>', "Vote up", :up, :add
    end
  end

  def vote_down_link
    case card.vote_status
    when '-'
      no_link :down, "You have already downvoted this claim."
    else
      vote_link '<i class="fa fa-chevron-down"></i>', "Vote down", :down, :add
    end
  end
  
  # def vote_up_link
  #   case vote_status
  #   when '+'
  #     no_link :up, "You have already upvoted this claim."
  #   when '-'
  #     vote_link '<i class="fa fa-chevron-up"></i>', "Withdraw upvote", :down, :drop
  #   when '?'
  #     vote_link '<i class="fa fa-chevron-up"></i>', "Vote up", :up, :add
  #   else
  #     vote_link '<i class="fa fa-chevron-up"></i>', "Vote up", :up, :add
  #     #no_link :up, "You have to sign in to vote for this claim."  #TODO redirect to sign-in page instead of this
  #   end
  # end
  #
  # def vote_down_link
  #   case vote_status
  #   when '+'
  #     vote_link '<i class="fa fa-chevron-down"></i>', "Withdraw upvote", :up, :drop
  #   when '-'
  #     no_link :down, "You have already downvoted this claim."
  #   when '?'
  #     vote_link '<i class="fa fa-chevron-down"></i>', "Vote down", :down, :add
  #   else
  #     no_link :up, "You have to sign in to vote for this claim."  #TODO redirect to sign-in page instead of this
  #   end
  # end
  
  view :core do |args |
    render_haml(:vote_status=>card.vote_status, :up_count=>card.left.upvote_count, :down_count=>card.left.downvote_count) do 
%{
.vote{:style=>"float:left; padding: 5px 5px 5px 10px; margin-right: 10px;"}
  .vote-up{:style=>"color: #bbb;"}
    = vote_up_link
    <i class="fa fa-users"></i>
    = up_count
    Important
  .vote-count{}
    = card.content
  .vote-down{:style=>"color: #bbb;"}
    = vote_down_link
    <i class="fa fa-users"></i>
    = down_count
    Not important
}   
    end
  end
end