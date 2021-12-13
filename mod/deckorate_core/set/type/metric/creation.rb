TAB_CONFIG =
  {
    researched: {
      help: "Answer values for <strong>Researched</strong> metrics are " \
            "directly entered or imported.",
      subtabs: %w[Standard Relationship]
    },
    calculated: {
      help: "Answer values for <strong>Calculated</strong> " \
            "metrics are dynamically calculated.",
      subtabs: %w[Formula Descendant Score WikiRating]
    }
  }.freeze

format :html do
  view :new do
    voo.title = "New Metric"
    with_nest_mode :edit do
      frame { _render_new_form }
    end
  end

  view :new_form, template: :haml, cache: :never

  def main_tabs
    tabs main_tab_hash, main_tab_from_subtab(params[:metric_type])
  end

  def main_tab_from_subtab subtab
    return unless subtab.present?

    subtab = subtab.to_name
    TAB_CONFIG.keys.find do |k|
      TAB_CONFIG[k][:subtabs].find { |s| s.to_name == subtab }
    end
  end

  def main_tab_hash
    TAB_CONFIG.keys.each_with_object({}) do |cat, hash|
      hash[cat] = { title: cat.capitalize, content: main_tab_content(cat) }
    end
  end

  def main_tab_content category
    haml :main_tab_content, category: category, help: TAB_CONFIG[category][:help]
  end

  def subtabs category
    tab_keys = TAB_CONFIG[category][:subtabs]
    tab_hash = subtab_tab_hash tab_keys
    metric_type = params[:metric_type] || tab_keys.first
    tabs tab_hash, metric_type, tab_type: :pills, load: :lazy do
      new_metric_subform metric_type
    end
  end

  def subtab_tab_hash tab_keys
    tab_keys.each_with_object({}) do |subcat, hash|
      hash[subcat] = { path: new_metric_subform_path(subcat) }
    end
  end

  view :new_metric_subform, cache: :never, unknown: true do
    new_metric_subform params[:metric_type]
  end

  def new_metric_subform_path metric_type
    path view: :new_metric_subform, type: :metric, metric_type: metric_type
  end

  def new_metric_subform metric_type
    new_metric = new_metric_of_type metric_type
    nest new_metric, { view: :new_tab_pane }, nest_mode: :normal
  end

  def new_metric_of_type metric_type
    metric_type = "Researched" if metric_type == "Standard"
    Card.new type: MetricID, "+*metric type" => "[[#{metric_type}]]"
  end

  def cancel_button_new_args
    { href: path_to_previous, redirect: true }
  end

  view :help_text, cache: :never do
    return "" unless (help_text_card = Card[card.metric_type + "+description"])
    class_up "help-text", "help-block"
    with_nest_mode :normal do
      render! :help, help: help_text_card.content
    end
  end

  view :new_tab_pane, unknown: true, cache: :never do
    with_nest_mode :edit do
      wrap do
        card_form :create, "data-main-success": JSON(redirect: true),
                           "data-slot-selector": ".new-view.TYPE-metric" do
          output [
            new_tab_pane_hidden,
            _render!(:help_text),
            _render_new_name_formgroup,
            _render_content_formgroups,
            _render_new_buttons
          ]
        end
      end
    end
  end

  def new_tab_pane_hidden
    hidden_tags(
      "card[subcards][+*metric type][content]" => "[[#{card.metric_type}]]",
      "card[type_id]" => MetricID
    )
  end

  view :new_name_formgroup, cache: :never do
    formgroup "Metric Name", input: "name", help: false do
      new_name_field
    end
  end

  def new_name_field form=nil, options={}
    form ||= self.form
    bs_layout do
      row 5, 1, 6 do
        column do
          metric_designer_field(options)
        end
        column do
          '<div class="plus">+</div>'
        end
        column do
          title_fields(options)
        end
      end
    end
  end

  def title_fields options
    metric_title_field(options)
  end

  def metric_designer_field options={}
    # I don't see a way to get options through to the form field
    # if options.present?
    #   label_tag(:designer, 'Metric Designer') +
    #     text_field('subcards[+designer]', {
    #       value: Auth.current.name,
    #       autocomplete: 'off'
    #     }.merge(options))
    # else
    designer = card.add_subfield_and_reset :designer, content: Auth.current.name,
                                                      type_id: PhraseID
    subformat(designer)
      ._render_edit_in_form(options.merge(title: "Metric Designer"))
    # end
  end

  def metric_title_field options={}
    title =
      card.add_subfield_and_reset :title, content: card.name.tag, type_id: PhraseID
    subformat(title)._render_edit_in_form(options.merge(title: "Metric Title"))
  end
end

def add_subfield_and_reset *args
  subfield = subfield(*args)
  subfield.reset_patterns
  subfield.include_set_modules
end
