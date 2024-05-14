card_accessor :description
card_accessor :multiple, type: :toggle

event :clear_corporate_identifier_caches, :integrate do
  %w[NAMES EXCERPTS].each do |suffix|
    Card.cache.delete "CORPORATE-IDENTIFIER-#{suffix}"
  end
end

def multiple?
  multiple_card.checked?
end

format :html do
  def edit_fields
    %i[description multiple]
  end

  view :core do
    render_read_form
  end
end

class << self
  def cards
    Card.search type: :corporate_identifier, sort: :name
  end

  def names
    Card.cache.fetch "CORPORATE-IDENTIFIER-NAMES" do
      cards.map do |ident|
        Type::WikirateCompany::Structure.corporate_identifier_accessor ident.codename
        ident.name
      end
    end
  end

  def excerpts
    Card.cache.fetch "CORPORATE-IDENTIFIER-EXCERPTS" do
      names.select do |name|
        excerpt? name.card.codename
      end
    end
  end

  def non_excerpts
    names - excerpts
  end

  private

  def excerpt? codename
    return unless codename

    fldmod = TypePlusRight::WikirateCompany.const_get_if_defined codename.to_s.camelcase
    fldmod&.include? Abstract::CompanyExcerpt
  end
end
