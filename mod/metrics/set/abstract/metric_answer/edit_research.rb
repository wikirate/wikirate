format :html do
  view :edit, wrap: :none do
    handle_research_params
    nest :research_page, view: :edit
  end

  view :research_edit_form, cache: :never, perms: :update, unknown: true do
    researchably do
      with_nest_mode :edit do
        wrap do
          card_form :update,
                    "main-success" => "REDIRECT",
                    "data-slot-selector": ".card-slot.slot_machine-view",
                    success: research_form_success do
            output [edit_view_hidden, _render_content_formgroup]
          end
        end
      end
    end
  end

  view :edit_year, cache: :never, perms: :update do
    researchably do
      wrap do
        research_form(:update) do
          haml :edit_year_form,
               slot_attr: "border-bottom p-2 pl-4 d-flex wd-100 justify-content-between "\
                          "flex-nowrap align-items-center"
        end
      end
    end
  end

  view :edit_buttons do
    class_up "form-group", "w-100 m-3"
    button_formgroup do
      [standard_save_button, cancel_research_button, answer_delete_button]
    end
  end

  def edit_year_cancel_button_path
    path research_params.merge mark: :research_page, view: :year_slot
  end

  def answer_delete_button
    confirm = "Are you sure you want to delete the #{card.metric_name} answer "\
              "for #{card.company_name} for #{card.year}?"
    success = research_params.merge(mark: :research_page.cardname)

    smart_link_to "Delete",
                  type: "button",
                  path: { action: :delete, success: success },
                  class: "btn btn-sm btn-outline-danger pull-right",
                  'data-confirm': confirm,
                  "data-disable-with": "Deleting"
  end
end
