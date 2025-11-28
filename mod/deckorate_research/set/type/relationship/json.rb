format :json do
  def lookup
    @lookup ||= card.lookup
  end

  def atom
    fields =
      %i[year value metric_id inverse_metric_id subject_company_id object_company_id]

    super().merge(lookup_fields(fields)).merge(
      import: lookup.imported,
      comments: field_nest(:discussion, view: :core),
      subject_company: lookup.subject_company_id.cardname,
      object_company: lookup.object_company_id.cardname
    )
  end

  def lookup_fields fields
    fields.each_with_object({}) do |field, hash|
      hash[field] = lookup.send field
    end
  end

  def molecule
    super().merge(subject_company: nest(card.company, view: :atom),
                  object_company: nest(card.related_company, view: :atom),
                  sources: field_nest(:source, view: :items),
                  checked_by: field_nest(:checked_by))
  end
end
