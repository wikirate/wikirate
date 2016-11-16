class Card::Metric
  class ValueCreator
    def initialize metric=nil, random_source=false, &values_block
      @metric = metric
      @random_source = random_source
      define_singleton_method(:add_values, values_block)
    end

    def create_value company, year, value
      args = { company: company.to_s, year: year }
      if value.is_a?(Hash)
        args.merge! value
      else
        args[:value] = value.to_s
      end
      if @metric.metric_type_codename == :researched && @random_source
        args[:source] ||= Card.search(type_id: Card::SourceID, limit: 1).first
      end
      @metric.create_value args
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
    # value (like a source for example) you can assign a hash the year
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
    # @option opts [Boolean] :random_source (false) pick a random source for
    #   each value
    def create opts, &block
      opts[:type] ||= :researched
      metric = Card.create! name: opts[:name],
                            type_id: Card::MetricID,
                            subcards: subcard_args(opts)
      metric.create_values opts[:random_source], &block if block_given?
      metric
    end

    def subcard_args opts
      subcards = {
        "+*metric type" => {
          content: "[[#{Card[opts[:type]].name}]]",
          type_id: Card::PointerID
        }
      }
      if opts[:formula]
        if opts[:formula].is_a?(Hash)
          opts[:formula] = opts[:formula].to_json
          opts[:value_type] ||= "Category"
        end

        subcards["+formula"] = {
          content: opts[:formula],
          type_id: Card::PhraseID
        }
      end
      if opts[:type] == :researched
        opts[:value_type] ||= "Number"
        subcards["+value type"] = {
          content: "[[#{opts[:value_type]}]]",
          type_id: Card::PointerID
        }
      end
      if opts[:value_options]
        subcards["+value options"] = {
          content: opts[:value_options].to_pointer_content,
          type_id: Card::PointerID
        }
      end
      subcards
    end
  end
end
