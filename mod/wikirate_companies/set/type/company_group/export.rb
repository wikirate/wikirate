format :json do
  KEYMAP = { company: :companies, specification: :specification }.freeze

  def atom
    super.merge fields_with_view(:content)
  end

  def molecule
    super.merge fields_with_view(:atom)
  end

  def fields_with_view view
    %i[specification company].each_with_object({}) do |codename, hash|
      hash[KEYMAP[codename]] = field_nest codename, view: view
    end
  end

  private

  def atom_content?
    false
  end
end
