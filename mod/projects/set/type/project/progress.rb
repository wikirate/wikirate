include_set Abstract::KnownAnswers

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

def worth_counting?
  metric_ids.any? && company_ids.any?
end

format :html do
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

  view :research_progress_bar, cache: :never do
    research_progress_bar
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

  def overall_progress_bar
    progress_bar(
        { value: card.percent_known, class: "progress-known" },
        { value: card.percent_unknown, class: "progress-unknown" },
        value: card.percent_not_researched, class: "progress-not-researched"
    )
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
end