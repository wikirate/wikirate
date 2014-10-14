
def vote_up
  case vote_status
  when '?'
    uv_card = Auth.current.upvotes_card
    if uv_card.add_id left.id
      uv_card.save!
      add_upvote
    end
  when '-'
    dv_card = Auth.current.downvotes_card
    if dv_card.drop_id left.id
      dv_card.save!
      delete_downvote
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

def add_upvote;      change_votecount :upvote,   1; end
def delete_upvote;   change_votecount :upvote,  -1; end
def add_downvote;    change_votecount :downvote, 1; end
def delete_downvote; change_votecount :downvote,-1; end

def change_votecount type, value
  case type
  when :upvote
    subcards[left.upvote_count_card.name] = (left.upvote_count.to_i + value).to_s
    self.content = (content.to_i + value).to_s
  when :downvote
    subcards[left.downvote_count_card.name] = (left.downvote_count.to_i + value).to_s
    self.content = (content.to_i - value).to_s
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
  
  def disabled_vote_link up_or_down, message
    "<i class=\"fa fa-chevron-#{up_or_down} disabled-vote-link vote-button\"></i>"
  end

  def vote_link text, title, up_or_down, extra={}
    path_hash = {:card=>card, :action=>:update, :view=>:core} #, 
    path_hash[:vote] = up_or_down
    
    link_to path(path_hash), 
        {:class=>"slotter vote-link vote-button", :title=>title, :remote=>true, :method=>'post',  :slotSelector=>".vote"}.merge(extra) do
      text
    end
  end


  def vote_up_link
    case card.vote_status
    when '+'
      disabled_vote_link :up, "You have already upvoted this claim."
    else
      vote_link '<i class="fa fa-chevron-up"></i>', "Vote up", :up
    end
  end

  def vote_down_link
    case card.vote_status
    when '-'
      disabled_vote_link :down, "You have already downvoted this claim."
    else
      vote_link '<i class="fa fa-chevron-down"></i>', "Vote down", :down
    end
  end
  
  view :core do |args |
    render_haml(:vote_status=>card.vote_status, :up_count=>card.left.upvote_count, :down_count=>card.left.downvote_count) do 
%{
.vote{:style=>"float:left; padding: 5px 5px 5px 10px; margin-right: 10px; margin-top:5px;"}
  %style
    :plain
      .vote-button {
      border: solid 1px #999; padding: 4px; margin-right: 5px;
      }
      .vote-link {
      color: #bbb; background-color: #eee;
      }
      .disabled-vote-link {
      color: #eee; background-color: #bbb; 
      }
      .vote-count {
      color: #444; font-face: bold; padding: 4px;
      }
      .vote-details {
      color: #bbb;
      }
  </style>
  .vote-up
    = vote_up_link
    %span.vote-details
      <i class="fa fa-users"></i>
      = up_count
      Important
  .vote-count
    = card.content
  .vote-down
    = vote_down_link
    %span.vote-details
      <i class="fa fa-users"></i>
      = down_count
      Not important
}   
    end
  end
end