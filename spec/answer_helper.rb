# Answer-related helper methods for specs
module AnswerHelper
  def create_answer args
    with_user(args.delete(:user) || "Joe User") do
      Card.create answer_args(args)
    end
  end

  def build_answer args
    Card.new answer_args(args)
  end

  def answer_args metric: sample_metric.name,
                  company: sample_company.name,
                  year: "2015",
                  value: "sample value",
                  source: sample_source.name
    {
      type_id: Card::MetricAnswerID,
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
  def create_metric opts={}, &block
    Card::Auth.as_bot do
      if opts[:name]&.to_name&.simple?
        opts[:name] = "#{Card::Auth.current.name}+#{opts[:name]}"
      end
      opts[:name] ||= "TestDesigner+TestMetric"
      Card::Metric.create opts, &block
    end
  end

  def have_badge_count num, klass, label
    have_tag "span.#{klass}" do
      with_tag "span.badge", text: /#{num}/
      with_tag "label", text: /#{label}/
    end
  end

  def html_trim str
    s = str.dup
    s.delete!("\r\n")
    s.delete!("\n")
    s.delete!("  ")
    s
  end
end
