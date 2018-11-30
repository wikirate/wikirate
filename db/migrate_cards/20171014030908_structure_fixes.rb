class StructureFixes < Card::Migration
  def up
    merge_cards [ "research_page+company",
                  "research page+metric",
                  "metric_value_source_form",
                  "source+*type+*structure",
                  "cardtype+*metric_type+*type_plus_right+*structure"
                ]
  end
end
