# -*- encoding : utf-8 -*-

class SourceTypeSetCards < Card::Migration
  def up
    %w(File Link Text).each do |name|
      create_source_type_set name
    end
  end

  def create_source_type_set name
    create_card!(
      name: "#{name}+*source type",
      type_id: Card::SetID,
      content: '{"type":"source",' +
               %("right_plus":["*source type", {"refer_to":"#{name}"}]})
    )
  end
end
