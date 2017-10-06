format :html do
  def humanized_attachment_name
    "csv file"
  end

  view :import, cache: :never do
    frame_and_form :update do
      [
        hidden_import_tags,
        render(:additional_form_fields),
        render(:import_table_helper),
        render(:import_table),
        render(:import_button_formgroup)
      ]
    end
  end

  def hidden_import_tags
    hidden_tags success: { name: card.import_status_card.name, view: :open }
  end

  view :import_button_formgroup do
    button_formgroup { [import_button, cancel_button(href: path)] }
  end

  def import_button
    button_tag "Import", class: "submit-button",
                         data: { disable_with: "Importing" }
  end

  view :import_table_helper do
    wrap_with(:p, group_selection_checkboxes) +
      wrap_with(:p, select_conflict_strategy)
  end

  view :additional_form_fields do
    ""
  end

  def group_selection_checkboxes
    <<-HTML.html_safe
      Select:
      <span class="padding-20 background-grey">
        #{check_box_tag '_check_all', '', false, class: 'checkbox-button'}
        #{label_tag 'all'}
      </span>
      #{group_selection_checkbox('exact', 'exact matches', :success, true)}
      #{group_selection_checkbox('alias', 'alias matches', :alias, true)}
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

  def select_conflict_strategy
    <<-HTML.html_safe
      Conflicts with existing entries:
      #{radio_button_tag "conflict", "skip", true} skip
      #{radio_button_tag "conflict", "override"} override
    HTML
  end
end
