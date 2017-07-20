class Card::Metric
  class ValueCreator
    def initialize metric=nil, random_source=false, &values_block
      @metric = metric
      @random_source = random_source
      define_singleton_method(:add_values, values_block)
    end

    def create_value company, year, value
      args = { company: company.to_s, year: year }
      if @metric.researched? && @random_source
        args[:source] ||= Card.search(type_id: Card::SourceID, limit: 1).first
      end
      if @metric.relationship?
        value.each do |company, relationship_value|
          @metric.create_value args.merge(related_company: company,
                                          value: relationship_value)
        end
      else
        if value.is_a?(Hash)
          args.merge! value
        else
          args[:value] = value.to_s
        end
        @metric.create_value args
      end
    end

    def method_missing company, *args
      args.first.each_pair do |year, value|
        create_value company, year, value
      end
    end

    def add_values_to metric
      @metric = metric
      add_values
    end
  end

  class << self
    # Creates a metric card.
    # A block can be used to create metric value cards for the metric using
    # the syntax
    # `company year => value, year => value`
    # If you want to define more properties of a metric value than just the
    # value (like a source for example) you can assign a hash to the year
    # @example
    # Metric.create name: 'Jedi+disturbances in the Force',
    #               value_type: 'Category',
    #               value_options: ['yes', 'no'] do
    #   Death_Star 1977 => { value: 'yes', source: 'http://deathstar.com' },
    #              1999 => 'no'
    #   Jar_Jar_Bings 1977 => 'no', 1999 => 'yes'
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
    # @option opts [String] :currency
    # @option opts [String] :unit
    # @option opts [Boolean] :random_source (false) pick a random source for
    #   each value
    def create opts, &block
      random_source = opts.delete :random_source
      metric = Card.create! name: opts.delete(:name),
                            type_id: Card::MetricID,
                            subfields: subfields(opts)
      metric.create_values random_source, &block if block_given?
      metric
    end

    # type is an alias for metric_type
    VALID_SUBFIELDS =
      ::Set.new([:metric_type, :currency, :formula, :value_type,
                 :value_options, :research_policy, :wikirate_topic, :unit, :report_type, :inverse_title])
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
      if type_id == Card::PointerID
        content = Array.wrap(content).to_pointer_content
      end
      { content: content, type_id: type_id }
    end

    def subfield_type_id field
      case field
      when :formula, :unit, :currency, :inverse_title then Card::PhraseID
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
      if opts[:formula].is_a? Hash
        opts[:formula] = opts[:formula].to_json
        opts[:value_type] ||= "Category"
      end

      opts[:metric_type] ||= :researched
      opts[:value_type] ||= "Number" if opts[:metric_type] == :researched
      opts[:metric_type] = Card.fetch_name opts[:metric_type]
    end
  end
end
