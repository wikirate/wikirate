format :html do
  def humanized_attachment_name
    "csv file"
  end

  view :import, cache: :never do
    frame_and_form :update, "notify-success" => "import successful" do
      [
        hidden_import_tags,
        _optional_render(:metric_select),
        _optional_render(:year_select),
        _optional_render(:import_flag),
        _optional_render(:import_table_helper),
        _render(:import_table),
        _render(:import_button_formgroup)
      ]
    end
  end

  def hidden_import_tags
    hidden_tags success: { id: "_self", view: :open }
  end

  view :import_button_formgroup do
    button_formgroup { [import_button, cancel_button(href: path)] }
  end

  def import_button
    button_tag "Import", class: "submit-button",
                         data: { disable_with: "Importing" }
  end

  view :year_select do
    nest card.left.year_card, view: :edit_in_form
  end

  view :metric_select do
    nest card.left.metric_card, view: :edit_in_form
  end

  view :import_flag do
    hidden_field_tag :is_data_import, "true"
  end

  view :import_table_helper do
    wrap_with :p, group_selection_checkboxes #+ import_legend)
  end

  def group_selection_checkboxes
    <<-HTML.html_safe
      Select:
      <span class="padding-20 background-grey">
        #{check_box_tag '_check_all', '', false, class: 'checkbox-button'}
        #{label_tag 'all'}
      </span>
      #{group_selection_checkbox('exact', 'exact matches', :success, true)}
      #{group_selection_checkbox('alias', 'alias matches', :active, true)}
      #{group_selection_checkbox('partial', 'partial matches', :info, true)}
      #{group_selection_checkbox('none', 'no matches', :warning)}
    HTML
  end

  def group_selection_checkbox name, label, identifier, checked=false
    wrap_with :span, class: "padding-20 table-#{identifier}" do
      [
        check_box_tag(
          name, "", checked,
          class: "checkbox-button _group_check",
          data: { group: identifier }
        ),
        label_tag(label)
      ]
    end
  end

  def import_legend
    <<-HTML.html_safe
     <span class="pull-right">
      company match:
      #{row_legend 'exact', 'success'}
      #{row_legend 'alias', 'info'}
      #{row_legend 'partial', 'warning'}
      #{row_legend 'none', 'danger'}
     <span>
    HTML
  end

  def row_legend text, context
    bs_label text, class: "bg-#{context}", style: "color: inherit;"
  end

  def bs_label text, opts={}
    add_class opts, "label"
    add_class opts, "label-#{opts.delete(:context)}" if opts[:context]
    wrap_with :span, text, opts
  end
end
