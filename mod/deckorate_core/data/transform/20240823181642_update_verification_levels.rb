# -*- encoding : utf-8 -*-

class UpdateVerificationLevels < Cardio::Migration::Transform
  def up
    # turn "steward added" into "steward verified"
    ::Record.where(verification: 2).update_all(verification: 4)

    # move verification index numbers to reflect removed level
    ::Record.where("verification > 2").update_all("verification = verification - 1")
  end
end
