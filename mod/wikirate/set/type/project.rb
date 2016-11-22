include_set Abstract::TwoColumnLayout

card_reader :wikirate_company
card_reader :metric
card_reader :organizer

# the space of possible metric records
def records
  @records ||= num_companies * num_metrics
end

def num_companies
  @num_companies ||= wikirate_company_card.item_names.size
end

def num_metrics
  @num_metrics ||= metric_card.item_names.size
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

def researched_wql
  { left_id: [:in] + metric_ids,
    right_id: [:in] + company_ids,
    return: :count }
end

# currently counts as researched if metric card exists at all
def researched
  @researched ||= worth_counting { Card.search(researched_wql) }
end

# researched and has a value that is not "Unknown"
def known
  @known ||= worth_counting do
    Card.search researched_wql.merge(
      right_plus: [{ type_id: YearID }, { ne: "Unknown" }]
    )
  end
end

def worth_counting
  return 0 unless metric_ids.any? && company_ids.any?
  yield
end

def unknown
  @unknown ||= researched - known
end

def not_researched
  @not_researched ||= records - researched
end

def percent_researched
  @percent_researched ||= percent_of_records researched
end

def percent_not_researched
  @percent_not_researched ||= percent_of_records not_researched
end

def percent_known
  @percent_known ||= percent_of_records known
end

def percent_unknown
  @percent_unknown ||= percent_of_records unknown
end

# returns with a tenth (eg 11.1%)
def percent_of_records value
  records.zero? ? 0 : (1000 * value / records / 10.0)
end

format :html do
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
      [
        field_nest(:organizer, view: :titled, items: { view: :link }),
        field_nest(:wikirate_topic, view: :titled, items: { view: :link }),
        field_nest(:description, view: :titled, items: { view: :link })
      ]
    end
  end

  view :content_right_col do
    wrap_with :div, class: "progress-column" do
      [
        overall_progress_box,
        field_nest(:metric, view: :titled, items: { view: :link }),
        field_nest(:wikirate_company, view: :titled, items: { view: :link })
      ]
    end
  end

  def overall_progress_box
    wrap_with :div, class: "overall-progress-box" do
      [
        progress_legend,
        bs_layout do
          row 3, 9 do
            column { percent_researched }
            column { main_progress_bar }
          end
        end
      ]
    end
  end

  def progress_legend
    wrap_with :div, class: "progress-legend" do
      "(legend)"
    end
  end

  def main_progress_bar
    wrap_with :div, class: "main-progress-bar" do
      [overall_progress_bar, progress_description]
    end
  end

  def progress_description
    "(nest editable card with description text)"
  end

  view :row do
    bs_layout do
      row 2, 10 do
        column { field_nest :image, size: :small }
        column { row_details }
      end
    end
  end

  def row_details
    output [
      wrap_with(:h4, _render_link),
      wrap_with(:div, organizational_details),
      wrap_with(:div, stats_details),
      wrap_with(:div, topics_details)
    ]
  end

  def organizational_details
    [
      field_nest(:wikirate_status, items: { view: :name }),
      "organized by #{field_nest :organizer, items: { view: :link }}"
    ].join " | "
  end

  def stats_details
    "#{count_stats} | #{percent_researched} #{overall_progress_bar}"
  end

  def percent_researched
    wrap_with :div, class: "percent-researched" do
      [
        wrap_with(:span, "#{card.percent_researched}%"),
        "Researched"
      ]
    end
  end

  def count_stats
    "#{card.num_companies} Companies, #{card.num_metrics} Metrics"
  end

  def topics_details
    field_nest :wikirate_topic, items: { view: :link, type: "Topic" }
  end

  def overall_progress_bar
    progress_bar(
      { value: card.percent_known, class: "progress-bar-success" },
      { value: card.percent_unknown, class: "progress-bar-info" },
      { value: card.percent_not_researched, class: "progress-bar-warning" }
    )
  end

  def progress_bar *sections
    wrap_with :div, class: "progress" do
      Array.wrap(sections).map do |section_args|
        progress_bar_section section_args
      end.join
    end
  end

  def progress_bar_section args
    add_class args, "progress-bar"
    wrap_with :div, class: args[:class], role: "progressbar",
                    style: "width: #{args[:value]}%" do
      args[:body] || "#{args[:value]}%"
    end
  end
end
