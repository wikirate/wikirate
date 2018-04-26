event :add_source_name_to_params, :finalize, on: :create do
  return unless success.params[:view] == "new_sources"
  save_in_session_card
end

def save_in_session_card save: false, duplicate: false
  return unless (company = Env.params.dig :card, :subcards, "+company", :content) &&
                (answer = Env.params[:answer])
  success.company = company
  return if duplicate && already_suggested?(answer)
  add_possible_source company, save
end

def already_suggested? answer
  Card.fetch(answer, new: { type_id: MetricValueID }).already_suggested?(name)
end

def add_possible_source company, save
  new_sources = add_subcard [company, :new_sources], type_id: SessionID
  new_sources.add_item name
  new_sources.save if save # if not in event phase we have to save
end

format :html do
  view :add_source_to_research, tags: :unknown_ok, perms: :create do
    with_nest_mode :edit do
      voo.type = "source"

      card_form :create, "main-success" => "REDIRECT",
                         "data-form-for" => "new_metric_value",
                         class: "slotter new-view TYPE-source" do
        output [
          new_research_hidden,
          new_view_type,
          haml(:source_form)
        ]
      end
    end
  end

  def answer
    voo.live_options[:answer] || Env.params[:answer]
  end

  def new_research_hidden
    hidden_tags success: { id: answer, type_id: MetricValueID,
                           soft_redirect: true, view: :new_sources },
                card: { subcards: { "+company": { content: Env.params[:company] } } },
                answer: answer,
                source: Env.params[:source]
  end

  def new_research_buttons
    wrap_with :div, class: "form-group" do
      wrap_with :div do
        wrap_with :button, "Add", class: "btn btn-primary",
                                  data: { disable_with: "Adding" }
      end
    end
  end
end
