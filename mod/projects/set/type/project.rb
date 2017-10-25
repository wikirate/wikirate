include_set Abstract::TwoColumnLayout
include_set Abstract::KnownAnswers
include_set Abstract::Thumbnail
include_set Abstract::Tabs
include_set Abstract::Export

card_reader :wikirate_company
card_reader :metric
card_reader :organizer

def all_related_answers
  Answer.where where_answer
end

def answers
  @answers ||= Answer.where(where_answer).where("updated_at > ?", created_at)
end

# the space of possible metric records
def num_records
  @num_records ||= num_companies * num_metrics
end

def num_companies
  @num_companies ||= wikirate_company_card.item_names.size
end

def num_metrics
  @num_metrics ||= metric_card.item_names.size
end

def num_users
  @num_users ||= answers.select(:creator_id).uniq.count
end

def num_answers
  @num_answers ||= answers.count
end

def num_policies
  d_cnt = 0
  c_cnt = 0
  metric_card.item_cards.each do |mc|
    next unless (policy = mc.try(:research_policy))
    case policy
    when "[[Designer Assessed]]" then d_cnt += 1
    when "[[Community Assessed]]" then c_cnt += 1
    end
  end
  [c_cnt, d_cnt]
end

def metric_ids
  @metric_ids ||= metric_card.item_names.map do |metric|
    Card.fetch_id metric
  end.compact
end

def company_ids
  @company_ids ||= wikirate_company_card.item_names.map do |company|
    Card.fetch_id company
  end.compact
end

def where_answer
  { metric_id: metric_ids, company_id: company_ids }
end

def worth_counting
  return 0 unless metric_ids.any? && company_ids.any?
  yield
end

format :html do
  view :open_content do |args|
    bs_layout container: false, fluid: true, class: @container_class do
      row 5, 7, class: "panel-margin-fix" do
        column _render_content_left_col, args[:left_class]
        column _render_content_right_col, args[:right_class]
      end
    end
  end

  def default_content_formgroup_args _args
    voo.edit_structure =
      [
        :image,
        :organizer,
        :wikirate_topic,
        :description,
        :metric,
        :wikirate_company
      ]
  end

  def header_right
    wrap_with :div, class: "header-right" do
      [
        wrap_with(:h3, _render_title, class: "project-title"),
        field_nest(:wikirate_status, view: :labeled)
      ]
    end
  end

  view :data do
    wrap_with :div, class: "progress-column" do
      left_col_content
    end
  end

  def left_col_content
    wrap_with :div do
      [
        field_nest(:organizer,
                   view: :titled,
                   title: "Organizer",
                   items: { view: :thumbnail_plain }),
        field_nest(:wikirate_topic,
                   view: :titled,
                   title: "Topics",
                   items: { view: :link }),
        field_nest(:description, view: :titled, title: "Description"),
        field_nest(:conversation,
                   view: :project_conversation, title: "Conversation")
      ]
    end
  end

  view :content_right_col do
    wrap_with :div, class: "progress-column" do
      [overall_progress_box, _render_tabs, _render_export_links]
    end
  end

  def tab_list
    {
      company_list_tab: "#{card.num_companies} Companies",
      metric_list_tab: "#{fa_icon 'bar-chart'} #{card.num_metrics} Metrics"
    }
  end

  view :metric_list_tab do
    standard_pointer_nest :metric
  end

  view :company_list_tab do
    standard_pointer_nest :wikirate_company
  end

  def overall_progress_box
    wrap_with :div, class: "overall-progress-box" do
      [
        progress_legend,
        bs_layout do
          row 2, 10 do
            column { _render_percent_researched }
            column { main_progress_bar }
          end
        end
      ]
    end
  end

  def progress_legend
    bs_layout do
      row 12 do
        column { wrap_legend_items }
      end
    end
  end

  def wrap_legend_items
    wrap_with :div, class: "progress-legend" do
      ["known", "unknown", "not-researched"].map { |i| legend_item i }
    end
  end

  def legend_item type
    wrap_with :div, class: "leg" do
      [
        progress_bar(value: 100, class: "progress-" + type),
        content_tag(:span, type.split(/ |\_|\-/).map(&:capitalize).join(" "))
      ]
    end
  end

  view :percent_researched do
    wrap_with :div, class: "percent-researched text-center" do
      [
        wrap_with(:div, class: "lead") do
          "<strong>#{card.percent_researched}%</strong>"
        end,
        "Researched"
      ]
    end
  end

  def main_progress_bar
    wrap_with :div, class: "main-progress-bar" do
      [_render_research_progress_bar, _render_progress_description]
    end
  end

  view :progress_description do
    %(
      <div class="text-muted small text-center">
        Of <strong>#{card.num_records} potential records</strong>
        (#{card.num_companies} Companies x #{card.num_metrics} Metrics),
        #{card.num_researched} have been added so far.
      </div>
    )
  end

  view :listing do
    image = card.field(:image)
    title = _render_link
    text = row_details
    bs_layout do
      row 12, class: "project-summary" do
        col text_with_image(image: image, size: :medium,
                            title: title, text: text)
      end
    end
  end

  def row_details
    wrap_with :div, class: "project-details-info" do
      [
        wrap_with(:div, class: "organizational-details") do
          organizational_details
        end,
        wrap_with(:div, class: "stat-details overall-progress-box") do
          stats_details
        end,
        wrap_with(:div, topics_details, class: "topic-details")
      ]
    end
  end

  def organizational_details
    organized_by = wrap_with :div, class: "organized-by horizontal-list" do
      [
        wrap_with(:span, " | organized by "),
        field_nest(:organizer, items: { view: :link })
      ]
    end
    status = field_nest(:wikirate_status, items: { view: :name })
    [status, organized_by]
  end

  def stats_details
    "#{count_stats} #{card.percent_researched}% #{overall_progress_bar}"
  end

  def count_stats
    wrap_with :span do
      "#{card.num_companies} Companies, #{card.num_metrics} Metrics | "
    end
  end

  def topics_details
    wrap_with :div, class: "horizontal-list" do
      field_nest :wikirate_topic, items: { view: :link, type: "Topic" }
    end
  end

  def overall_progress_bar
    progress_bar(
      { value: card.percent_known, class: "progress-known" },
      { value: card.percent_unknown, class: "progress-unknown" },
      value: card.percent_not_researched, class: "progress-not-researched"
    )
  end
end

format :csv do
  view :core do
    Answer.csv_title + all_related_answers.map(&:csv_line).flatten.join
  end
end

format :json do
  view :core do
    _render_essentials.merge(answers: answers)
  end

  def answers
    card.all_related_answers.map do |answer|
      subformat(answer)._render_core
    end
  end

  def essentials
    {
      metrics: nest(card.metric_card, view: :essentials, hide: :marks),
      companies: nest(card.wikirate_company_card, view: :essentials, hide: :marks)
    }
  end
end
