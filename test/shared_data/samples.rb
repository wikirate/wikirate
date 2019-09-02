
class SharedData
  module Samples
    METRIC_COUNT = 19

    METRIC_NAMES = {
      free_text: "Jedi+Sith Lord in Charge",
      number: "Jedi+deadliness",
      category: "Jedi+disturbances in the Force",
      money: "Jedi+cost of planets destroyed"
    }.freeze

    def metric_count
      SharedData::Samples::METRIC_COUNT
    end

    # cards only exist in testing db
    def sample_note num=1
      notes = ["Death Star uses dark side of the Force", "Fruits are round"]
      Card[notes[num - 1]]
    end

    def sample_company index=0
      Card[SharedData::COMPANIES.keys[index]]
    end

    def sample_topic index=0
      Card[SharedData::TOPICS.keys[index]]
    end

    def sample_companies num=1, args={}
      search_samples  Card::WikirateCompanyID, num, args
    end

    def sample_topics num=1, args={}
      search_samples Card::WikirateTopicID, num, args
    end

    def sample_metrics num=1, args={}
      search_samples Card::MetricID, num, args
    end

    def sample_metric value_type=:free_text
      Card[METRIC_NAMES[value_type]]
    end

    def sample_answer value_type=:free_text
      Card["#{METRIC_NAMES[value_type]}+Death_Star+1977"]
      #sample_metric(value_type).random_value_card
    end

    def sample_project
      Card["Evil Project"]
    end

    # @param source [String] existing examples you can choose from
    # are :space_opera, :opera, :apple, and :star_wars
    def sample_source source=:opera
      Card[:"#{source}_source"]
    end

    def sample_metric_answer value_type=:free_text
      Card["#{METRIC_NAMES[value_type]}+Death_Star+1977"]
    end

    private

    def search_samples type_id, num, args={}
      Card.search args.merge(type_id: type_id, limit: num)
    end
  end
end

