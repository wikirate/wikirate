# -*- encoding : utf-8 -*-

# Update permission rules for
class GiveDesignerAssessedACodename < Card::Migration
  def up
    ensure_card "Designer assessed", codename: "designer_assessed"

    { "discussion+*right" => "[[Anyone Signed In]]",
     "Metric value+value+*type plus right" => "_left",
     "Metric value+source+*type plus right" => "_left" }.each do |set, content|
      %w(create update delete).each do |action|
      ensure_card "#{set}+*#{action}", content: content
    end
  end
end
