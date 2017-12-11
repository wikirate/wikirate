include_set Abstract::Relationship

event :ensure_inverse, :validate, on: :create do
  return if new_inverse_title.present? || inverse_title.present?
  errors.add :name, "no inverse title given"
end

event :validate_inverse, :validate, after: :ensure_inverse do
  return if !inverse_title || inverse_title == new_inverse_title
  errors.add :name, "the inverse of '#{metric_title}' is already defined as '#{inverse_title}'"
end

event :create_inverse, :prepare_to_store, on: :create do
  inverse = new_inverse_title || inverse_title
  inverse_name = "#{metric_designer}+#{inverse}"
  add_subcard inverse_name, type: MetricID,
                            subfields: { metric_type: "Inverse Relationship", inverse: name }
  add_subfield :inverse, content: inverse_name, type: :pointer
  add_title_inverse_pointer metric_title, inverse
end

def new_inverse_title
  inverse_field = subfield(:inverse_title)
  inverse_field&.content.present? && inverse_field.content
end

def add_title_inverse_pointer title, inverse
  add_subcard [inverse, :inverse], content: title, type_id: Card::PointerID
  add_subcard [title, :inverse], content: inverse, type_id: Card::PointerID
end

format :html do
  def title_fields options
    wrap_with :div do
      [
        metric_title_field(options),
        inverse_title_field(options)
      ]
    end
  end

  def metric_title_field options
    super options.merge help: "<p>How company A relates to company B, e.g. company A is <strong>owner of</strong> company B</p>"
  end

  def inverse_title_field options={}
    title = card.add_subfield :inverse_title, content: card.name.tag,
                                              type_id: PhraseID
    title.reset_patterns
    title.include_set_modules
    subformat(title)._render_edit_in_form(options.merge(title: "Inverse Title"))
  end
end
