# -*- encoding : utf-8 -*-

class ImportNewMetric < Card::Migration
  def up
    CSV.foreach(data_path("first_metrics_to_import.csv"), headers: true, header_converters: :symbol, converters: :all) do |row|
      Card::Auth.current_id = Card.fetch_id row[:creator]
      Card::Auth.as_bot do
        subcards = {}
        subcards["+about"] = { content: row[:about] } if row[:about]
        subcards["+methodology"] = { content: row[:methodology] } if row[:methodology]
        if topics = row[:topics]
          topic_str = ""
          topics.split(";").each do |t|
            topic_str += "[[#{t}]]\n"
          end
          subcards["+topics"] = { content: topic_str, type_id: Card::PointerID }
        end
        subcards["+value type"] = { content: row[:value_type].capitalize } if row[:value_type]
        subcards["+question"] = { content: row[:question] } if row[:question]
        subcards["+unit"] = { content: row[:unit].to_s, type_id: Card::PhraseID } if row[:unit]
        subcards["+range"] = { content: row[:range].to_s, type_id: Card::PhraseID } if row[:range]
        Card.create name: "#{row[:designer]}+#{row[:name]}", type: :metric, subcards: subcards
      end
    end
  end
end
