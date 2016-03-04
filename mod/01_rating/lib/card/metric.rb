class Card::Metric
  # Usage:
  # Card::Metric.create type: :researched do
  #   Siemens 2015: 4, 2014: 3
  #   Apple   2105: 7
  # end

  class ValueCreator
    def initialize metric=nil, &values_block
      @metric = metric
      define_singleton_method(:add_values, values_block)
    end

    def create_value company, year, value
      args = { company: company, year: year }
      if value.is_a?(Hash)
        if (source_url = value.delete :source)
          args['+source'] = {
            subcards: {
              'new source1' => {
                '+Link' => {
                  content: source_url,
                  type_id: Card::PhraseID
                }
              }
            }
          }
        end
        args.merge! value
      else
        args[:value] = value
      end
      if @metric.metric_type_codename == :researched
        args[:source] ||= get_a_sample_source
      end
      @metric.create_value args
    end

    def method_missing company, *args
      args.first.each_pair do |year, value|
        create_value company, year, value.to_s
      end
    end

    def add_values_to metric
      @metric = metric
      add_values
    end
  end

  class << self
    def create opts, &block
      opts[:type] ||= :researched
      subcards = {
        '+*metric type' => {
          content: "[[#{Card[opts[:type]].name}]]",
          type_id: Card::PointerID
        }
      }
      if opts[:type] == :researched
        opts[:value_type] ||= 'Number'
        subcards['+value type'] = {
          content: "[[#{opts[:value_type]}]]",
          type_id: Card::PointerID
        }
      end
      if opts[:formula]
        subcards['+formula'] = {
          content: opts[:formula],
          type_id: Card::PhraseID
        }
      end
      metric = Card.create! name: opts[:name],
                            type_id: Card::MetricID,
                            subcards: subcards
      ValueCreator.new(metric, &block).add_values if block_given?
      metric
    end
  end

  def with_values &block
    ValueCreator.new(metric, &block).add_values
  end


end
