include_set Abstract::Researched

format :html do
  def properties
    super.merge research_properties
  end
end
