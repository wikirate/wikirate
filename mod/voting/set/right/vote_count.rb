
def vote_up
  case vote_status
  when '?'
    uv_card = Auth.current.upvotes_card
    if uv_card.add_id left.id
      uv_card.save!
      update_votecount
    end
  when '-'
    dv_card = Auth.current.downvotes_card
    if dv_card.drop_id left.id
      dv_card.save!
      update_votecount
    end
  end
end

def vote_down
  case vote_status
  when '?'
    dv_card = Auth.current.downvotes_card
    if dv_card.add_id left.id
      dv_card.save!
      update_votecount
    end
  when '+'
    uv_card = Auth.current.upvotes_card
    if uv_card.drop_id left.id
      uv_card.save!
      update_votecount
    end
  end
end

# def add_upvote;      change_votecount :upvote,   1; end
# def delete_upvote;   change_votecount :upvote,  -1; end
# def add_downvote;    change_votecount :downvote, 1; end
# def delete_downvote; change_votecount :downvote,-1; end
#
# def change_votecount type, value
#   case type
#   when :upvote
#     subcards[left.upvote_count_card.name] = (left.upvote_count.to_i + value).to_s
#     self.content = (content.to_i + value).to_s
#   when :downvote
#     subcards[left.downvote_count_card.name] = (left.downvote_count.to_i + value).to_s
#     self.content = (content.to_i - value).to_s
#   end
# end

def update_votecount 
  up_count = Card.search( :plus=>[{:codename=>'upvotes'},:link_to=>left.name], :return=>'count' )
  down_count = Card.search( :plus=>[{:codename=>'downvotes'},:link_to=>left.name], :return=>'count')
  subcards[left.upvote_count_card.name] = up_count.to_s
  subcards[left.downvote_count_card.name] = down_count.to_s
  self.content = (up_count - down_count).to_s
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

event :vote, :before=>:approve, :on=>:update, :when=>proc{ |c| Env.params['vote'] } do
  if Auth.signed_in?
    case Env.params['vote']
    when 'up' then vote_up
    when 'down' then vote_down
    end
  else
   path_hash = {:card=>self, :action=>:update, 
                 :success=>{:id=>left.name}, :vote=>Env.params['vote'] }
   self.format.save_interrupted_action path_hash
   abort :success => "REDIRECT: #{Card[:signin].cardname.url_key}"
  end
end


format :html do  
  
  def disabled_vote_link up_or_down, message, extra={}
    button_tag({:disabled=>true, 
        :class=>"slotter disabled-vote-link vote-button", :type=>'button', :title=>message}.merge(extra)) do
      "<i class=\"fa fa-angle-#{up_or_down} fa-4x\"></i>"
    end
  end

  def vote_link text, title, up_or_down, extra={}
    path_hash = {:card=>card, :action=>:update, :view=>:core} #, 
    path_hash[:vote] = up_or_down
    
    button_tag({:href=>path(path_hash), 
        :class=>"slotter vote-link vote-button", :type=>'button', :title=>title, :remote=>true, :method=>'post',  :slotSelector=>".vote"}.merge(extra)) do
      text
    end
  end


  def vote_up_link
    case card.vote_status
    when '+'
      disabled_vote_link :up, "You have already upvoted this claim."
    else
      vote_link '<i class="fa fa-angle-up fa-4x"></i>', "Vote up", :up
    end
  end

  def vote_down_link
    case card.vote_status
    when '-'
      disabled_vote_link :down, "You have already downvoted this claim."
    else
      vote_link '<i class="fa fa-angle-down fa-4x"></i>', "Vote down", :down
    end
  end
  
  view :core do |args |
    render_haml(:vote_status=>card.vote_status, :up_count=>card.left.upvote_count, :down_count=>card.left.downvote_count) do 
%{
%style
  :plain
    .vote {
    padding: 5px 5px 5px 5px;
    }
    
    .vote-button, .vote-button:hover {
    border: solid 1px #ccc; border-radius:0; padding: 0; margin: 0; 
    margin-right: 5px; 
    width: 30px; 
    height: 30px; 
    background: none;
    font-size: 6px;
    text-align: center;
    font-weight: normal;
    }

    .vote-link {
    color: #888; background-color: #eee;
    }
    .disabled-vote-link, .disabled-vote-link:hover {
    color: #fff; background-color: #bbb; 
    }
    
    .vote-count {
    color: #555; 
    width: 30px; 
    height: 25px; 
    text-align: center; 
    padding-top: 4px;
    font-weight: bold;
    }
    
    .vote-details {
    color: #bbb;
    font-size: 14px;
    padding-top: 7px;
    }
    .vote-number {
    font-weight: bold;
    }
    
.vote
  .vote-up
    = vote_up_link
    %span.vote-details
      <i class="fa fa-users"></i>
      %span.vote-number
        = up_count
      Important
  .vote-count
    = card.content
  .vote-down
    = vote_down_link
    %span.vote-details
      <i class="fa fa-users"></i>
      %span.vote-number
        = down_count
      Not important
}   
    end
  end
end
