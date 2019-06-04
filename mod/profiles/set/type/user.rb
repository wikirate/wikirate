include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail

CONTRIBUTION_TYPES = %i[metric_answer metric wikirate_company project
                        source wikirate_topic research_group].freeze

format :html do
  delegate :badge_count, to: :card

  before :content_formgroup do
    voo.edit_structure = [:image, "+about me", :discussion]
  end

  view :open_content do
    two_column_layout 5, 7
  end

  def header_text
    wrap_with :div, class: "badges-earned" do
      content_tag :h3, medal_counts("horizontal")
    end
  end

  view :data do
    wrap_with :div, class: "profile-data" do
      [
        field_nest("+about me", view: :titled, title: "About me"),
        field_nest(:discussion, view: :titled, show: :comment_box)
      ]
    end
  end

  def type_link_label
    "Researcher"
  end

  def tab_list
    %i[research_group contributions activity]
  end

  def tab_options
    {
      contributions: { count: nil, label: "Contributions" },
      activity: { count: nil, label: "Activity" }
    }
  end

  view :research_group_tab, cache: :never do
    field_nest :research_group, items: { view: :bar, hide: :bar_middle }
  end

  view :contributions_tab, cache: :never do
    CONTRIBUTION_TYPES.map do |codename|
      user_and_type = card.fetch trait: codename, new: {}
      nest user_and_type, view: :contribution_report
    end.join
  end

  view :activity_tab, cache: :never do
    field_nest :activity
  end
end
