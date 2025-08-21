# -*- encoding : utf-8 -*-

class StewardAssessed < Cardio::Migration::Transform
  def up
    "Steward Assessed".card.delete!
    "Designer Assessed".card.update! name: "Steward Assessed", codename: :steward_assessed
  end
end
