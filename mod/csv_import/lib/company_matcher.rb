# Match company names to companies in the database
class CompanyMatcher
  COMPANY_MAPPER_THRESHOLD = 0.5
  MATCH_TYPE_ORDER = { none: 1, partial: 2, alias: 3, exact: 4 }

  def initialize company_name
    @company_name = company_name
    @match_result = nil
  end

  def match
    @match_result ||= find_match
  end

  def suggestion
    none? ? @company_name : match_name
  end

  def match_type
    match[1]
  end

  def match_name
    match[0]
  end

  MATCH_TYPE_ORDER.keys.each do |key|
    define_method "#{key}?" do
      match_type == key
    end
  end

  def any?
    !none?
  end

  def <=> b
    MATCH_TYPE_ORDER[match_type] <=> MATCH_TYPE_ORDER[b.match_type]
  end

  private

  def find_match
    return no_match unless @company_name.present?
    find_exact_match || find_alias_match || find_partial_match || no_match
  end

  def no_match
    ["", :none]
  end

  def find_exact_match
    return unless (company = Card.quick_fetch(@company_name)) &&
                  company.type_id == Card::WikirateCompanyID
    [company.name, :exact]
  end

  def find_alias_match
    return unless (alias_name = ::Company::Alias[@company_name])
    [alias_name, :alias]
  end

  def find_partial_match
    id = self.class.mapper.map(@company_name, COMPANY_MAPPER_THRESHOLD)
    return unless id && (name = Card.fetch_name(id))
    [name, :partial]
  end

  class << self
    include ::NewRelic::Agent::MethodTracer

    def mapper
      @mapper ||= Company::Mapping::CompanyMapper.new corpus
    end

    def corpus
      @corpus ||= init_corpus
    end

    def init_corpus
      corpus = Company::Mapping::CompanyCorpus.new
      Card.search(type_id: Card::WikirateCompanyID, return: :id).each do |company_id|
        company_name = Card.fetch_name(company_id)
        aliases = (a_card = Card[company_name, :aliases]) && a_card.item_names
        corpus.add company_id, company_name, (aliases || [])
      end
      corpus
    end

    def add_to_mapper company_id, company_name
      return unless @mapper # if the mapping tool is not cached, no need to update it
      aliases = (a_card = Card[company_name, :aliases]) && a_card.item_names
      corpus.add company_id, company_name, (aliases || [])
      @mapper = Company::Mapping::CompanyMapper.new corpus
    end

    add_method_tracer :add_to_mapper, "CompanyMatcher/add_to_mapper"

    def reset_mapper
      @mapper = nil
      @corpus = nil
    end
  end
end
