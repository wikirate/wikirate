include_set Abstract::Relation

# value is calculated later...
def value_required?
  false
end

def answer_lookup_field
  :answer_id
end

def metric_lookup_field
  :metric_id
end

def relationship_lookup_id
  id
end

def company_id_field
  :subject_company_id
end

def inverse_company_id_field
  :object_company_id
end

event :ensure_inverse, :validate, on: :create do
  return if new_inverse_title.present? || inverse_title.present?
  errors.add :name, "no inverse title given"
end

event :validate_inverse, :validate, after: :ensure_inverse do
  return if !inverse_title || inverse_title == new_inverse_title
  errors.add :name,
             "the inverse of '#{metric_title}' is already defined as '#{inverse_title}'"
end

event :create_inverse, :prepare_to_store, on: :save do
  inverse = new_inverse_title || inverse_title
  inverse_name = "#{metric_designer}+#{inverse}"
  subcard inverse_name, type: :metric,
                        fields: { metric_type: :inverse_relation.cardname,
                                  inverse: name }
  field :inverse, content: inverse_name, type: :pointer
  add_title_inverse_pointer metric_title, inverse
end

event :delete_relationships,
      :prepare_to_validate, on: :update, trigger: :required do
  if !Card::Auth.always_ok?
    # TODO: come up with better permissions scheme for this!
    # maybe something like `perms: :admin` in the event def?
    errors.add :answers, "only admins can bulk delete answers"
  else
    with_company_from_params do |company|
      delete_answers_for_company company
      true
    end
  end
end

def with_company_from_params
  company = company_from_params
  if !company
    errors.add :company, "params must specify valid company"
  else
    yield company
  end
end

format :html do
  def table_properties
    if voo.hide? :relationship_properties
      super.select { |k, _v| k != :metric_type }
    else
      super.merge inverse: "Inverse Metric"
    end
  end

  def title_fields
    wrap_with(:div) { [metric_title_field, inverse_title_field] }
  end

  def metric_title_field
    help = "How company A relates to company B.<br/> " \
           "e.g. A is <strong>owner of</strong> B"
    name_part_field :title, card.name.right, title: "Metric Title", help: help
  end

  def inverse_title_field
    help = "How company B relates to company A.<br/> " \
           "e.g. B is <strong>is owned by</strong> A"
    name_part_field :inverse_title, card.name.right, title: "Inverse Title", help: help
  end
end

private

def new_inverse_title
  inverse_field = field(:inverse_title)
  inverse_field&.content.present? && inverse_field.content
end

def add_title_inverse_pointer title, inverse
  subcard [inverse, :inverse], content: title, type: :pointer
  subcard [title, :inverse], content: inverse, type: :pointer
end

def delete_answers_for_company company
  delete_subject_answer_for_company company
  delete_object_answers_for_company company
end

def delete_subject_answer_for_company company
  return unless (answer_card = Card.fetch(self, company))
  delete_as_subcard answer_card
end

def delete_object_answers_for_company company
  object_answers_for_company(company).each do |answer_card|
    delete_as_subcard answer_card
  end
end

def object_answers_for_company company
  Card.search left: { left: { left_id: id } },
              type_id: Card::RelationshipID,
              right: company
end

def company_from_params
  return unless (company_name = Env.params[:company])
  company = Card[company_name]
  return unless company&.type_id == Card::CompanyID
  company_name
end
