class Card::Metric
  class AnswerCreator
    def initialize metric=nil, test_source=false, &answers_block
      @metric = metric
      @test_source = test_source
      define_singleton_method(:add_answers, answers_block)
    end

    def create_answer company, year, value
      variant = @metric.relationship? ? :relationship : :standard
      send "create_#{variant}_answer", value, create_answer_args(company, year)
    end

    def add_answers_to metric
      @metric = metric
      add_answers
    end

    private

    def create_relationship_answer value, args
      value.each do |company, relationship_value|
        @metric.create_answer args.merge(related_company: company,
                                        value: relationship_value)
      end
    end

    def create_standard_answer value, args
      if value.is_a? Hash
        args.merge! value
      else
        args[:value] = value.to_s
      end
      @metric.create_answer args
    end

    def create_answer_args company, year
      args = { company: company.to_s, year: year }
      prep_source args
      args
    end

    def prep_source args
      return unless @metric.researchable? && @test_source
      args[:source] ||= test_source_card
    end

    def test_source_card
      test_source_mark = @test_source == true ? :opera_source : @test_source
      Card[test_source_mark]
    end

    def method_missing company, *args
      args.first.each_pair do |year, value|
        create_answer company, year, value
      end
    end
  end

  class << self
    # Creates a metric card.
    # A block can be used to create metric answer cards for the metric using
    # the syntax
    # `company year => value, year => value`
    # If you want to define more properties of a metric answer than just the
    # value (like a source for example) you can assign a hash to the year
    # @example
    # Metric.create name: 'Jedi+disturbances in the Force',
    #               value_type: 'Category',
    #               value_options: ['yes', 'no'] do
    #   Death_Star 1977 => { value: 'yes', source: 'http://deathstar.com' },
    #              1999 => 'no'
    #   Jar_Jar_Binks 1977 => 'no', 1999 => 'yes'
    # end
    # @params [Hash] opts metric properties
    # @option opts [String] :name the name of the metric. Use the common
    #   pattern Designer+Title(+Scorer)
    # @option opts [Symbol] :type (:researched) one of the four metric types
    #   :researched, :score, :formula, or :wiki_rating
    # @option opts [String, Hash] :formula the formula for a calculated
    #   metric. Use a hash for a metric of 'categorical' value type to translate
    #   value options
    # @option opts [String] :value_type ('Number') if the
    #   formula is a hash then it defaults to 'Category'
    # @option opts [Array] :value_options the options that you can choose of
    #   for a metric value
    # @option opts [Array, String] :research_policy research policy
    #   (designer or community assessed)
    # @option opts [Array, String] :topic tag with topics
    # @option opts [String] :unit
    # @option opts [Boolean] :test_source (false) pick a random source for
    #   each answer
    def create opts, &block
      test_source = opts.delete :test_source
      metric = Card.create! name: opts.delete(:name),
                            type_id: Card::MetricID,
                            subfields: subfields(opts)
      metric.create_answers test_source, &block if block_given?
      metric
    end

    # type is an alias for metric_type
    VALID_SUBFIELDS =
      ::Set.new([:metric_type, :formula, :value_type, :hybrid,
                 :value_options, :research_policy, :wikirate_topic, :unit, :report_type,
                 :inverse_title])
           .freeze
    ALIAS_SUBFIELDS = { type: :metric_type, topic: :wikirate_topic, inverse: :inverse_title }.freeze

    def subfields opts
      resolve_alias opts
      validate_subfields opts
      normalize_subfields opts

      opts.each_with_object({}) do |(field, content), subfields|
        subfields[field] = subfield_args field, content
      end
    end

    def subfield_args field, content
      type_id = subfield_type_id(field)
      content = Array.wrap(content).to_pointer_content if type_id == Card::PointerID
      { content: content, type_id: type_id }
    end

    def subfield_type_id field
      case field
      when :formula, :unit, :inverse_title
        Card::PhraseID
      when :hybrid
        Card::ToggleID
      else Card::PointerID
      end
    end

    def resolve_alias opts
      ALIAS_SUBFIELDS.each do |alias_key, key|
        opts[key] = opts.delete(alias_key) if opts.key? alias_key
      end
    end

    def validate_subfields opts
      invalid = ::Set.new(opts.keys) - VALID_SUBFIELDS
      return if invalid.empty?
      raise ArgumentError, "invalid metric subfields: #{invalid.to_a}"
    end

    def normalize_subfields opts
      opts[:formula] = opts[:formula].to_json if opts[:formula].is_a? Hash
      opts[:metric_type] ||= :researched
      opts[:value_type] ||= "Number"
      opts[:metric_type] = Card.fetch_name opts[:metric_type]
    end
  end
end
