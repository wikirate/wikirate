class Card::Metric
  # @example
  # create_values do
  #   Siemens 2015 => 4, 2014 => 3
  #   Apple   2105 => 7
  # end
  def create_values &block
    ValueCreator.new(self, &block).add_values
  end

  class ValueCreator
    def initialize metric=nil, &values_block
      @metric = metric
      define_singleton_method(:add_values, values_block)
    end

    def create_value company, year, value
      args = { company: company.to_s, year: year }
      if value.is_a?(Hash)
        args.merge! value
      else
        args[:value] = value.to_s
      end
      if @metric.metric_type_codename == :researched
        args[:source] ||= get_a_sample_source
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
    # create a metric card
    # a block can be used to create values using the syntax
    # `company year => value`
    # @params [Hash] opts metric properites
    # @option opts [String] :name
    # @option opts [Symbol] :type (':researched') one of the metric types
    # :reasearched, :score, :formula, or :wiki_rating
    # @option opts [String, Hash] :formula the formula for a calculated metric
    # @option opts [String] :value_type ('Number') if the
    #    formula is a hash then it defaults to 'Categorical'
    # @option opts [Array] :value_options the options that can be choosen for
    #    a metric vaule
    # @example
    # Metric.create name: 'Jedi+disturbances in the Force',
    #               value_type: 'Categorical',
    #               value_options: ['yes', 'no'] do
    #   Death_Star 1977 => { value: 'yes', source: 'http://deathstar.com' },
    #              1999 => 'no'
    #   Jar_Jar_Bings 1977 => 'no', 1999 => 'yes'
    # end
    def create opts, &block
      opts[:type] ||= :researched
      metric = Card.create! name: opts[:name],
                            type_id: Card::MetricID,
                            subcards: subcard_args(opts)
      metric.create_values &block if block_given?
      metric
    end

    def subcard_args opts
      subcards = {
        '+*metric type' => {
          content: "[[#{Card[opts[:type]].name}]]",
          type_id: Card::PointerID
        }
      }
      if opts[:formula]
        if opts[:formula].is_a?(Hash)
          opts[:formula] = opts[:formula].to_json
          opts[:value_type] ||= 'Categorical'
        end

        subcards['+formula'] = {
          content: opts[:formula],
          type_id: Card::PhraseID
        }
      end
      if opts[:type] == :researched
        opts[:value_type] ||= 'Number'
        subcards['+value type'] = {
          content: "[[#{opts[:value_type]}]]",
          type_id: Card::PointerID
        }
      end
      if opts[:value_options]
        subcards['+value options'] = {
          content: opts[:value_options].to_pointer_content,
          type_id: Card::PointerID
        }
      end
      subcards
    end
  end
end
