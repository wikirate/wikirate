module Deckorate
  # test-only API for creating metrics
  class MetricCreator
    class << self
      # type is an alias for metric_type
      VALID_FIELDS =
        ::Set.new(
          %i[metric_type formula value_type hybrid variables value_options rubric
             assessment topic unit report_type inverse_title]
        ).freeze
      ALIAS_FIELDS = {
        type: :metric_type, topic: :topic, inverse: :inverse_title
      }.freeze

      # Creates a metric card.
      # A block can be used to create answer cards for the metric using
      # the syntax
      # `company year => value, year => value`
      # If you want to define more properties of an answer than just the
      # value (like a source for example) you can assign a hash to the year
      # @example
      # create_metric name: 'Jedi+disturbances in the Force',
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
      #   :researched, :score, :formula, or :rating
      # @option opts [String, Hash] :formula the formula for a calculated
      #   metric. Use a hash for a metric of 'categorical' value type to translate
      #   value options
      # @option opts [String] :value_type ('Number') if the
      #   formula is a hash then it defaults to 'Category'
      # @option opts [Array] :value_options the options that you can choose of
      #   for a metric value
      # @option opts [Array, String] :assessment assessment
      #   (designer or community assessed)
      # @option opts [Array, String] :topic tag with topics
      # @option opts [String] :unit
      def create opts
        Card.create! name: opts.delete(:name), type: :metric, fields: fields(opts)
      end

      private

      def fields opts
        resolve_alias opts
        validate_fields opts
        normalize_fields opts
        opts
      end

      def resolve_alias opts
        ALIAS_FIELDS.each do |alias_key, key|
          opts[key] = opts.delete(alias_key) if opts.key? alias_key
        end
      end

      def validate_fields opts
        invalid = ::Set.new(opts.keys) - VALID_FIELDS
        return if invalid.empty?
        raise ArgumentError, "invalid metric fields: #{invalid.to_a}"
      end

      def normalize_fields opts
        opts[:metric_type] ||= :researched
        opts[:value_type] ||= "Number"
        opts[:metric_type] = opts[:metric_type].cardname
      end
    end
  end
end
