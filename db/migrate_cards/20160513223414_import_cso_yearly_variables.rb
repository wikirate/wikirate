# -*- encoding : utf-8 -*-

class ImportCsoYearlyVariables < Card::Migration
  DATA = {
    'Maximum Allowable OECD CO2 Emissions' => [
      11475, 11550, 11625, 11701, 11776, 11851, 11743, 11634, 11525,
      11417, 1130
    ],
    'Maximum Allowable OECD CO2 Emissions - Ratio to Baseline' => [
      1.0000, 1.0066, 1.0131, 1.0197, 1.0262, 1.0328, 1.0233, 1.0139, 1.0044,
      0.9949, 0.9855
    ],
    'GDP of OECD' => [
      36447627200000, 39127218500000, 41294669500000, 42561395200000,
      41687612000000, 43446674000000, 45324766700000, 46576648200000,
      47694954500000, 49289717300000, 50521960232500
    ]
  }.freeze

  def up
    DATA.each_pair do |name, values|
      subcards = {}
      2006.upto(2015).with_index do |year, i|

        subcards["+#{year}"] = { type_id: Card::YearlyAnswerID,
                                 "+value" => {
                                   type_id: Card::YearlyValueID,
                                   content: values[i]
                                 }
                               }
      end
      Card.create! name: "Center for Sustainable Organizations+#{name}",
                   type_id: Card::YearlyVariableID,
                   subcards: subcards
    end
  end
end
