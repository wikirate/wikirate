# -*- encoding : utf-8 -*-

class ImportNewMetric < Card::Migration
  def up
    CSV.foreach(data_path("first_metrics_to_import.csv"),:headers => true, :header_converters => :symbol, :converters => :all) do |row|
      Card::Auth.current_id = Card.fetch_id row[:creator]
      Card::Auth.as_bot do
        subcards = { }
        subcards.merge!({'+about'=>{:content=>row[:about]}}) if row[:about]
        subcards.merge!({'+methodology'=>{:content=>row[:methodology]}}) if row[:methodology]
        subcards.merge!({'+topics'=>{:content=>"[[#{row[:topics]}]]",:type_id=>Card::PointerID}}) if row[:topics]
        subcards.merge!({'+question'=>{:content=>row[:question]}}) if row[:question]
        subcards.merge!({'+unit'=>{:content=>row[:unit].to_s,:type_id=>Card::PhraseID}}) if row[:unit]
        subcards.merge!({'+range'=>{:content=>row[:range].to_s,:type_id=>Card::PhraseID}}) if row[:range]
        Card.create :name=>"#{row[:designer]}+#{row[:name]}",:type=>:metric,:subcards=>subcards
      end
    end
  end
end
