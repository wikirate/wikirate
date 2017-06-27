include_set Abstract::MetricChild, generation: 3
include_set Abstract::Answer


def related_company
  cardname.tag
end

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

  view :content_formgroup, template: :haml do
    card.add_subfield :year, content: card.year
    card.add_subfield :related_company, content: card.related_company
  end
end
