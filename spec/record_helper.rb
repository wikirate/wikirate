module Deckorate
  # Record-related helper methods for specs
  module RecordHelper
    def create_record args
      with_user(args.delete(:user) || "Joe User") do
        Card.create record_args(**args)
      end
    end

    def build_record args
      Card.new record_args(**args)
    end

    def record_args metric: sample_metric.name,
                    company: sample_company.name,
                    year: "2015",
                    value: "sample value",
                    source: sample_source.name
      {
        type: :record,
        "+metric" => metric,
        "+company" => company,
        "+value" => value,
        "+year" => year,
        "+source" => source
      }
    end

    # Usage:
    # create_metric type: :researched do
    #   Siemens 2015: 4, 2014: 3
    #   Apple   2105: 7
    # end
    # @option opts [Boolean] :test_source (false) pick a random source for each record
    def create_metric opts={}, &block
      test_source = opts.delete :test_source
      Card::Auth.as_bot do
        create_metric_opts opts
        Deckorate::MetricCreator.create(opts).tap do |metric|
          create_records(metric, test_source, &block) if block_given?(&block)
        end
      end
    end

    def have_badge_count num, klass, label
      have_tag "span.#{klass}" do
        with_tag "span.badge", text: /#{num}/
        with_tag "label", text: /#{label}/
      end
    end

    def check_record record_card
      record_card.checked_by_card.update! trigger: :add_check
    end

    def create_records metric, test_source=false, &block
      Deckorate::RecordCreator.new(metric.card, test_source, &block).add_records
    end

    private

    def create_metric_opts opts
      if opts[:name]&.to_name&.simple?
        opts[:name] = "#{Card::Auth.current.name}+#{opts[:name]}"
      end
      opts[:name] ||= "TestDesigner+TestMetric"
    end
  end
end