def virtual?
  true
end

format :html do
  view :core do |_args|
    Card::Act.where(
      "actor_id=#{card.left.id} and card_id is not NULL"
    ).order("acted_at DESC").limit(10).map do |act|
      next unless (main_action = act.main_action) &&
                  !main_action.draft &&
                  (act_card = act.card) && !act_card.trash
      item = {
        time: time_ago_in_words(act.acted_at),
        card: act_card,
        action: act.main_action.action_type
      }
      wrap_with :div, class: "activity" do
        activity_item(item)
      end
    end.join "\n"
  end

  def action_info card, action_type
    card_type = if card.type_id == Card::BasicID
                  " card"
                else
                  card.type_name.downcase
                end
    format("%sd %s%s", action_type, ("a new " if action_type == :create), card_type)
  end

  def activity_item item
    %(
      <span class="time">#{item[:time]} ago</span>
      #{glyphicon 'stop'}
      <span class="activity-action">#{action_info item[:card], item[:action]}
      </span>
      <span>#{link_to_card item[:card]}</span>

    ).html_safe
  end

  view :open do |args|
    card.left.present? && card.left.account ? super(args) : ""
  end
end
