def ok_to_join?
  Auth.signed_in? && !current_user_is_member?
end

def current_user_is_member?
  item_cards.find { |item_card| item_card.id == Auth.current_id }
end

def joining?
  Env.params[:join].present?
end

event :join_group, :validate, when: :joining? do
  abort :failure, "cannot join this group" unless ok_to_join?
  add_item Auth.current.name
end

format :html do
  view :overview, tags: :unknown_ok do
    wrap { haml :overview }
  end

  view :contributions, tags: :unknown_ok do
    return "" unless card.count.positive?
    with_paging do |paging_args|
      table_content = member_contribution_content members_on_page(paging_args)
      table table_content, header: member_contribution_header
    end
  end

  def members_on_page paging_args
    wql = { referred_to_by: card.name, type_id: UserID, sort: :name }
    Card.search wql.merge! paging_args.extract!(:limit, :offset)
  end

  view :join_button, tags: :unknown_ok, denial: :blank, cache: :never,
                     perms: ->(r) { r.card.ok_to_join? } do
    link_to "Join", path: { action: :update, join: true, success: { view: :overview } },
                    class: "btn btn-primary slotter", remote: true
  end

  view :manage_button, tags: :unknown_ok do
    link_to_view("edit", "Manage Researcher List", class: "btn slotter")
  end

  def member_contribution_header
    contribution_categories.map do |category|
      Card::Set::LtypeRtype::User::Cardtype::ACTION_LABELS[category]
    end.unshift "Answers"
  end

  def contribution_categories
    [:created, :updated, :discussed, :double_checked]
  end

  def member_contribution_content members
    members.map do |member|
      contribution_categories.map do |category|
        card.left.contribution_count member.name, :metric_value, category
      end.unshift nest(member, view: :thumbnail)
    end
  end
end
