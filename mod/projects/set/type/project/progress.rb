include_set Abstract::KnownAnswers

# override
def project_card
  self
end

# the space of possible metric records
def num_possible
  @num_possible ||= num_possible_records * (years ? num_years : 1)
end

def num_possible_records
  @num_possible_records ||= num_companies * num_metrics
end

def num_companies
  @num_companies ||= wikirate_company_card.valid_company_cards.size
end

def num_metrics
  @num_metrics ||= metric_card.valid_metric_cards.size
end

def num_years
  @num_years ||= year_card.valid_year_cards.size
end

def num_users
  @num_users ||= answers.select(:creator_id).uniq.count
end

def num_answers
  @num_answers ||= answers.count
end

def units
  years ? "answers" : "records"
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
    %(<div class="text-muted small text-center">
        Of <strong>#{card.num_possible} potential #{card.units}</strong>
        (#{formula}), <strong>#{card.num_researched}</strong> have been added so far.
      </div>)
  end

  def formula
    [:company, :metric, (:year if card.years)].compact.map do |var|
      icon, stat_method, title = Layout::TAB_MAP[var]
      "#{card.send stat_method} #{title} #{fa_icon icon}"
    end.join " x "
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
