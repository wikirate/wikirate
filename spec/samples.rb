
module Deckorate
  # sample data for use in tests
  module Samples
    METRIC_COUNT = 21

    METRIC_NAMES = {
      free_text: "Jedi+Sith Lord in Charge",
      number: "Jedi+deadliness",
      category: "Jedi+disturbances in the Force",
      money: "Jedi+cost of planets destroyed"
    }.freeze

    def metric_count
      METRIC_COUNT
    end

    def sample_company
      "Death Star".card
    end

    def sample_topic
      %i[esg_topics environment].cardname.card
    end

    def sample_metrics num=1, args={}
      search_samples Card::MetricID, num, args
    end

    def sample_metric value_type=:free_text
      Card[METRIC_NAMES[value_type]]
    end

    def sample_answer value_type=:free_text
      Card["#{METRIC_NAMES[value_type]}+Death_Star+1977"]
      # sample_metric(value_type).random_value_card
    end

    def sample_project
      "Evil Project".card
    end

    # @param source [String] existing examples you can choose from
    # are :space_opera, :opera, :apple, and :star_wars
    def sample_source source=:opera
      Card[:"#{source}_source"]
    end

    private

    def search_samples type_id, num, args={}
      Card.search args.merge(type_id: type_id, limit: num)
    end
  end
end
