include_set Abstract::MetricChild, generation: 3
include_set Abstract::Answer

format :html do
  def default_value_link_args _args
    voo.show! :link if card.relationship?
  end

  view :open_content do
    bs do
      layout do
        row 3, 9 do
          column value_field
          column do
            row 12 do
              column _render_answer_details
            end
          end
        end
      end
    end
  end
end
