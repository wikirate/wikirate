format :json do
  NESTED_FIELD_CODENAMES =
    %i[wikipedia open_corporates alias headquarters oar_id sec_cik].freeze

  view :links do
    []
  end

  view :items do
    []
  end

  def atom
    super.tap do |h|
      h.delete :content
      add_fields_to_hash h, :core
    end
  end

  def molecule
    super.tap do |h|
      add_fields_to_hash(h)
      h[:answers_url] = path mark: card.name.field(:metric_answer), format: :json
    end
  end

  def add_fields_to_hash hash, view=:atom
    NESTED_FIELD_CODENAMES.each do |fieldcode|
      hash[fieldcode] = field_nest fieldcode, view: view
    end
  end
end
