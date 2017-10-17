class StructureFixes < Card::Migration
  def up
    merge_cards [ "research page+company",
                  "research page+metric",
                  "metric value source form",
                  "source+*type+*structure",
                  "Cardtype+*metric type+*type plus *structure",
                  "File+*source type",
                  "Text+*source type",
                  "Link+*source type"
                ]
  end
end
