format :json do
  def atom
    nucleus.merge fields_with_view(:content)
  end

  def molecule
    super.merge fields_with_view(:atom)
  end

  def fields_with_view view
    %i[file wikirate_link report_type title wikirate_company year description discussion
       metric metric_answer].each_with_object({}) do |codename, hash|

      hash[codename.cardname.downcase.tr(" ", "_")] = field_nest codename, view: view
    end
  end
end
