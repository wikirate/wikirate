format :html do
  view :new do
    voo.title = "New Metric"
    with_nest_mode :edit do
      frame { _render_new_form }
    end
  end

  view :new_form, template: :haml do
    @tabs =
      {
        researched: {
          help: "Answer values for <strong>Researched</strong> metrics are "\
                "directly entered or imported.",
          subtabs: %w[Standard Relationship]
        },
        calculated: {
          help: "Answer values for <strong>Calculated</strong> "\
                "metrics are dynamically calculated.",
          subtabs: %w[Formula Descendant Score WikiRating]
        }
      }
  end

  def tab_pane_id name
    "#{name.downcase}Pane"
  end

  def selected_tab_pane? tab
    tab == current_tab
  end

  def current_tab
    @current_tab ||= begin
      subtab = params[:tab]&.underscore&.to_sym
      subtab && Card[subtab].calculated? ? :calculated : :researched
    end
  end

  def selected_subtab_pane? name
    if params[:tab]
      params[:tab].casecmp(name).zero?
    else
      name == "Standard" || name == "Formula"
    end
  end

  def new_metric_tab_pane name
    metric_type = name == "Standard" ? "Researched" : name
    new_metric = new_metric_of_type metric_type
    tab_form = nest new_metric, { view: :new_tab_pane }, nest_mode: :normal
    tab_pane tab_pane_id(name), name, tab_form, selected_subtab_pane?(name)
  end

  def new_metric_of_type metric_type
    new_metric = Card.new type: MetricID, "+*metric type" => "[[#{metric_type}]]"
    new_metric.reset_patterns
    new_metric.include_set_modules
    new_metric
  end

  def cancel_button_new_args
    { href: path_to_previous, redirect: true }
  end

  view :help_text do
    return "" unless (help_text_card = Card[card.metric_type + "+description"])
    class_up "help-text", "help-block"
    with_nest_mode :normal do
      render! :help, help: help_text_card.content
    end
  end

  view :new_tab_pane, tags: :unknown_ok do
    with_nest_mode :edit do
      wrap do
        card_form :create, "main-success" => "REDIRECT",
                           "data-slot-selector": ".new-view.TYPE-metric" do
          output [
            new_tab_pane_hidden,
            _render!(:help_text),
            _render_new_name_formgroup,
            _render_content_formgroup,
            _render_new_buttons
          ]
        end
      end
    end
  end

  def new_tab_pane_hidden
    hidden_tags(
      "card[subcards][+*metric type][content]" => "[[#{card.metric_type}]]",
      "card[type_id]" => MetricID,
      success: "_self"
    )
  end

  view :new_name_formgroup do
    formgroup "Metric Name", editor: "name", help: false do
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
    title = card.add_subfield_and_reset :title, content: card.name.tag, type_id: PhraseID
    subformat(title)._render_edit_in_form(options.merge(title: "Metric Title"))
  end
end

def add_subfield_and_reset *args
  subfield = add_subfield(*args)
  subfield.reset_patterns
  subfield.include_set_modules
end
