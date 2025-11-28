format :json do
  def atom
    nucleus.merge(fields_with_view(atom_fields, :content))
  end

  def molecule
    super.merge(fields_with_view(molecule_fields, :atom))
  end

  def atom_fields
    %i[file wikirate_link report_type wikirate_title year]
  end

  def molecule_fields
    atom_fields + %i[description discussion company metric answer]
  end

  def fields_with_view fields, view
    fields.each_with_object({}) do |codename, hash|
      key = codename.cardname.downcase.tr(" ", "_").to_sym
      hash[key] = field_nest codename, view: view
    end
  end
end
