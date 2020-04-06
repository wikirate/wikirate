# name pattern: Metric+Subject Company+Year+Object Company

include_set Abstract::MetricChild, generation: 3
include_set Abstract::MetricAnswer
include_set Abstract::DesignerPermissions

require_field :value
require_field :source, when: :source_required?

def lookup
  ::Relationship.where(relationship_id: id).take
end

def related_company
  name.tag
end

def related_company_card
  Card[related_company]
end

def name_parts
  %w[metric company year related_company]
end

def valid_related_company?
  (related_company_card&.type_id == Card::WikirateCompanyID) ||
    ActManager.include?(related_company)
end

def valid_answer_name?
  super && valid_related_company?
end

def value_type_code
  metric_card.value_type_code
end

def value_cardtype_code
  metric_card.value_cardtype_code
end

# has to happen after :set_answer_name,
# but always, also if :set_answer_name is not executed
event :schedule_answer_counts, :finalize do
  schedule_answer_count answer_name
  schedule_answer_count inverse_answer_name
end

def schedule_answer_count name
  answer_card = Card.fetch name, new: { type_id: Card::MetricAnswerID,
                                        "+value" => "1" }
  answer_card.try :schedule_answer_count
  add_subcard answer_card
end

def answer_id
  @answer_id ||= Card.fetch_id answer_name
end

def answer_name
  name.left
end

def inverse_answer_name
  [metric_card.inverse, related_company, year].join "+"
end

def inverse_answer_id
  @inverse_answer_id ||= Card.fetch_id inverse_answer_name
end

def answer
  @answer ||= Card.fetch(answer_name)&.answer
end

format :html do
  view :open_content do
    bs do
      layout do
        row 3, 9 do
          column render_basic_details
          column do
            row 12 do
              column _render_expanded_details
            end
          end
        end
      end
    end
  end

  view :content_formgroup do
    card.add_subfield :year, content: card.year
    card.add_subfield :related_company, content: card.related_company
    super()
  end

  def legend
    subformat(card.metric_card).value_legend
  end
end

format :json do
  def atom
    super().merge year: card.year.to_s,
                  value: card.value,
                  import: card.imported?,
                  comments: field_nest(:discussion, view: :core),
                  subject_company: Card.fetch_name(card.company),
                  object_company: Card.fetch_name(card.related_company)
  end

  def molecule
    super().merge subject_company: nest(card.company, view: :atom),
                  object_company: nest(card.related_company, view: :atom)
  end
end
