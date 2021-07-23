format :json do
  KEYMAP = { wikirate_company: :companies, specification: :specification }.freeze

  def atom
    nucleus.merge fields_with_view(:content)
  end

  def molecule
    super.merge fields_with_view(:atom)
  end

  def fields_with_view view
    %i[specification wikirate_company].each_with_object({}) do |codename, hash|
      hash[KEYMAP[codename]] = field_nest codename, view: view
    end
  end
end
