def virtual?; true end

format :html do
  view :core do |args|
    Card::Act.where(:actor_id=>card.left.id).order('acted_at DESC').limit(10).map do |act|
      if (main_action = act.main_action) && (!main_action.draft) && (!act.card.trash)
        item = {
          :time => time_ago_in_words(act.acted_at),
          :card => act.card,
          :action => act.main_action.action_type
        }
        content_tag :div, :class=>'activity' do
          activity_item(item)
        end
      end
    end.join "\n"
  end

  def action_info card, action_type
    card_type = if card.type_id == Card::BasicID
                  ' card'
                else
                  binding.pry unless card.type_name
                  card.type_name.downcase
                end
    "%sd %s%s" % [action_type, ('a new ' if action_type == :create), card_type]
  end

  def activity_item item
    %{
      <span class="time">#{item[:time]} ago</span>
      #{glyphicon 'stop'}
      <div>
        #{action_info item[:card], item[:action]}
        <p>#{card_link item[:card]}</p>
      </div>
    }.html_safe
  end

  view :open do |args|
    if !card.accountable? && !card.account
      ''
    else
      super(args)
    end
  end

end