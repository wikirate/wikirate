include_set Abstract::ListCachedCount

CONTRIBUTION_CATEGORIES = %i[created updated discussed double_checked].freeze
CONTRIBUTION_CATEGORY_HEADER = ["Answers"].concat(
  CONTRIBUTION_CATEGORIES.map do |category|
    Card::Set::LtypeRtype::User::Cardtype::ACTION_LABELS[category]
  end
)

def current_member?
  Auth.current_id.in? item_ids
end

def current_organizer?
  Auth.current_id.in?(left.organizer_card.item_ids)
end

def ok_to_read?
  super || current_member? || current_organizer?
end

def ok_to_update?
  super || current_organizer?
end

def ok_to_join?
  Auth.signed_in? && !current_member?
end

event :join_group, :validate, trigger: :required do
  abort :failure, "cannot join this group" unless ok_to_join?
  add_item! Auth.current.name
  abort :success
end

event :leave_group, :validate, trigger: :required do
  drop_item! Auth.current.name
  abort :success
end

format do
  def contribution_counts member
    Error.rescue_card member do
      CONTRIBUTION_CATEGORIES.map do |category|
        card.left.contribution_count member.name, :answer, category
      end
    end
  end
  # rescue StandardError => e
  #   Card::Error.report e, member
  #   count_errors
  # def count_errors
  #   CONTRIBUTION_CATEGORIES.size.times.with_object([]) { |_num, arr| arr << "ERROR" }
  # end
end

format :html do
  delegate :ok_to_join?, :current_member?, to: :card

  def self.membership_button action, test, btnclass
    view "#{action}_button".to_sym,
         unknown: true, denial: :blank, cache: :never, perms: test do
      link_to "#{action.to_s.capitalize} Group",
              path: { action: :update,
                      card: { trigger: "#{action}_group" },
                      success: { view: :overview } },
              class: "btn #{btnclass} btn-sm slotter",
              remote: true
    end
  end

  membership_button :join, :ok_to_join?, "btn-primary"
  membership_button :leave, :current_member?, "btn-outline-primary"

  view :overview, unknown: true, wrap: :slot, perms: :none, template: :haml, cache: :never

  view :contributions, unknown: true, cache: :never, denial: :blank do
    return "" unless card.count.positive?
    with_paging do |paging_args|
      table_content = member_contribution_content members_on_page(paging_args)
      table table_content, header: CONTRIBUTION_CATEGORY_HEADER
    end
  end

  view :manage_button, unknown: true, denial: :blank, perms: :update do
    link_to_view "edit", "Manage Researcher List",
                 class: "btn btn-outline-primary btn-sm"
  end

  def default_limit
    10
  end

  private

  def members_on_page paging_args
    Card::Auth.as_bot do
      cql = { referred_to_by: card.name, sort_by: :name, right_plus: :account }
      Card.search cql.merge!(paging_args.extract!(:limit, :offset))
    end
  end

  def member_contribution_content members
    members.map do |member|
      [nest(member, view: :thumbnail)].concat contribution_counts(member)
    end
  end
end
