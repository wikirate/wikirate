include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Stewardable
include_set Abstract::ProfileType

# include_set Abstract::Bookmarker

CONTRIBUTION_TYPES = %i[answer metric company project
                        source topic research_group].freeze

card_reader :projects_organized, type: :search_type
card_reader :metrics_designed, type: :search_type

format :html do
  delegate :badge_count, to: :card

  before :content_formgroups do
    voo.edit_structure = [:image, "+about me", :discussion]
  end

  def tab_list
    %i[details research_group bookmarks contributions activity].tap do |list|
      list << :simple_account if simple_account_tab?
    end
  end

  view :details_tab do
    wrap_with :div, class: "profile-data" do
      [
        field_nest("+about me", view: :titled, title: "About me"),
        field_nest(:discussion, view: :titled, show: :comment_box)
      ]
    end
  end

  view :simple_account_tab do
    [
      field_nest(:account_settings),
      field_nest(:account, view: :api_key, items: { view: :content })
    ]
  end

  view :research_group_tab do
    field_nest :research_group, items: { view: :bar, hide: :bar_middle }
  end

  view :contributions_tab, cache: :never do
    CONTRIBUTION_TYPES.map do |codename|
      user_and_type = card.fetch codename, new: {}
      nest user_and_type, view: :contribution_report
    end.join
  end

  view :bookmarks_tab do
    field_nest :bookmarks
  end

  view :activity_tab, cache: :never do
    field_nest :activity
  end

  def type_link_label
    "Researcher"
  end

  def simple_account_tab?
    card.current_account? || card.account&.ok?(:read)
  end

  def tab_options
    {
      contributions: { count: nil, label: "Contributions" },
      activity: { count: nil, label: "Activity" },
      simple_account: { count: nil, label: "Account" }
    }
  end

  def header_text
    wrap_with :div, class: "badges-earned" do
      content_tag :h3, medal_counts("horizontal")
    end
  end
end
