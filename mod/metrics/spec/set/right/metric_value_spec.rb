describe Card::Set::Right::MetricValue do
  describe "views" do
    # before do
    #   login_as "joe_user"
    #   @metric = sample_metric
    #   @metric.update_attributes! subcards:
    #     { "+Unit" => { content: "Imperial military units",
    #                    type_id: Card::PhraseID }
    #     }
    #   @company = sample_company
    #   subcards = {
    #     "+metric"  => { content: @metric.name },
    #     "+company" => { content: "[[#{@company.name}]]",
    #                     type_id: Card::PointerID },
    #     "+value"   => { content: "I'm fine, I'm just not happy.",
    #                     type_id: Card::PhraseID },
    #     "+year"    => { content: "2015",
    #                     type_id: Card::PointerID },
    #     "+source" =>  { subcards: { "new source" => { "+Link" =>
    #                     { content: "http://www.google.com/?q=everybodylies",
    #                       type_id: Card::PhraseID
    #                     }
    #                   } } } }
    #   @metric_value = Card.create! type_id: Card::MetricValueID,
    #                                subcards: subcards
    #   @card = Card.fetch @metric, @company, :metric_value
    # end
  end
end
