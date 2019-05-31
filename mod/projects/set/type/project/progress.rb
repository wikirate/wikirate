include_set Abstract::KnownAnswers

# override
def project_card
  self
end

# the space of possible metric records
def num_possible
  @num_possible ||= num_possible_records * year_multiplier
end

# used to calculate possible records/answers
def year_multiplier
  @year_multiplier ||= years ? num_years : 1
end

def num_possible_records
  @num_possible_records ||= num_companies * num_metrics
end

def num_companies
  @num_companies ||= wikirate_company_card.num
end

def num_metrics
  @num_metrics ||= metric_card.num
end

def num_years
  @num_years ||= year_card.num
end

def num_users
  @num_users ||= answers.select(:creator_id).uniq.count
end

def num_answers
  @num_answers ||= answers.count
end

def num_subprojects
  @num_subprojects ||= subproject_card.count
end

def units
  years ? "answers" : "records"
end

format :html do
  delegate :units, to: :card

  view :overall_progress_box, cache: :never do
    overall_progress_box false
  end

  def overall_progress_box legend=true
    wrap_with :div, class: "default-progress-box" do
      [
        (progress_legend if legend),
        bs_layout do
          row 9, 3 do
            column { main_progress_bar }
            column { render_percent_researched }
          end
        end
      ]
    end
  end

  # view :percent_researched do
  #   wrap_with :div, class: "percent-researched text-center border rounded" do
  #     [
  #       wrap_with(:h4, class: "border-bottom p-2 m-0 bg-light") do
  #         "<strong>#{card.percent_researched}%</strong>"
  #       end,
  #       wrap_with(:span, "Researched", class: "text-muted")
  #     ]
  #   end
  # end

  def main_progress_bar
    wrap_with :div, class: "main-progress-bar mt-1" do
      [_render_research_progress_bar, _render_progress_description]
    end
  end

  view :research_progress_bar, cache: :never do
    research_progress_bar
  end

  # view :progress_description do
  #   %(<div class="text-muted">
  #       Of <strong>#{card.num_possible} potential #{card.units}</strong>
  #       (#{formula}), <strong>#{card.num_researched}</strong> have been added so far.
  #     </div>)
  # end

  view :percent_researched, template: :haml do
    @percent = card.percent_researched
  end

  view :progress_description, template: :haml  do
    @num_possible = card.num_possible
    @formula = formula
    @num_researched = card.num_researched
  end

  def formula
      [:wikirate_company, :metric, (:year if card.years)].compact.map do |codename|
      "#{options[codename][:count]} #{codename.cardname.vary :plural}"
    end.join " x "
  end

  def progress_legend
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
