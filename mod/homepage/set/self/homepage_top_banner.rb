include_set Abstract::HamlFile

format :html do
  def haml_locals
    { companies: ["Apple", "Samsung", "Alphabet", "Novartis", "L’Oreal", "Barcalys"],
      topics: ["Climate Change", "Environment", "Human Rights", "Digital Rights", "Corporate Governence", "SDG5: Gender Equality"],
      adjectives: ["excellent", "open"]
     }
  end
end
