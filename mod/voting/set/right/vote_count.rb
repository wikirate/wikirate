
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
  view :missing  do |args|
    if card.new_card?
      Auth.as_bot { card.save! }
      render(args[:denied_view],args)
    else
      super(args)
    end
  end
  
  def disabled_vote_link up_or_down, message, extra={}
    button_tag({:disabled=>true, 
        :class=>"slotter disabled-vote-link vote-button", :type=>'button', :title=>message}.merge(extra)) do
      "<i class=\"fa fa-angle-#{up_or_down} fa-4x\"></i>"
    end
  end

  def vote_link text, title, up_or_down, view, extra={}
    path_hash = {:card=>card, :action=>:update, :view=>view} #, 
    path_hash[:vote] = up_or_down
    
    button_tag({:href=>path(path_hash), 
        :class=>"slotter vote-link vote-button", :type=>'button', :title=>title, :remote=>true, :method=>'post'}.merge(extra)) do
      text
    end
  end



  def vote_up_link success_view
    link = case card.vote_status
    when '+'
      disabled_vote_link :up, "You have already upvoted this claim."
    else
      vote_link '<i class="fa fa-angle-up fa-4x"></i>', "Vote up", :up, success_view
    end
  end

  def vote_down_link success_view
    link = case card.vote_status
    when '-'
      disabled_vote_link :down, "You have already downvoted this claim."
    else
      vote_link '<i class="fa fa-angle-down fa-4x"></i>', "Vote down", :down, success_view
    end
  end
  

  def wrap_with_class css_class
     "<div class=\"#{css_class}\">#{output yield}</div>"
  end
  
  view :content do |args|
    wrap args.merge(:slot_class=>'card-content nodblclick') do
      [
        _optional_render( :menu, args, :hide ),
        wrap_with_class('vote-up') { vote_up_link(:content) },
        _render_core( args ),
        wrap_with_class('vote-down') {vote_down_link(:content) }
      ]
    end
  end
  
  view :core do |args|
    wrap_with_class('vote-count') do
      super(args)
    end
  end
  
  def up_details 
    render_haml :up_count=>card.left.upvote_count do %{
%span.vote-details
  <i class="fa fa-users"></i>
  %span.vote-number
    = up_count
  Important
      }
    end
  end
  
  def down_details
    render_haml :down_count=>card.left.downvote_count do %{
%span.vote-details
  <i class="fa fa-users"></i>
  %span.vote-number
    = down_count
  Not important
      }
    end
  end
  
  view :details do |args |
    wrap args.merge(:slot_class=>'nodblclick') do 
      [
        wrap_with_class('vote-up') do 
          [
            vote_up_link(:details),
            up_details
          ]
        end, 
        _render_core( args ),
        wrap_with_class('vote-down') do
          [
            vote_down_link(:details),
            down_details
          ]
        end 
      ]      
    end
  end
end
