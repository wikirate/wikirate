class StructureFixes < Card::Migration
  def up
    merge_cards [ "research page+company", "research page+metric", "metric value source form", "source+*type+*structure",
                  "*metric_type+*right+*structure", "*source_type+*right+*structure"]
  end
end
