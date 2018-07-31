include_set Abstract::HamlFile

format :html do

  def haml_locals
    { categories: [:company, :metric_questions, :metric_answers, :source],
      colors: [:company, :metric, :metric, :source],
      icons: [icon_map(:wikirate_company), :help, :check, icon_map(:source) ]
     }
  end
end
