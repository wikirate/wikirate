# -*- encoding : utf-8 -*-

class UpdateContributionCount < Card::Migration
  def up
    %w( claim page analysis company topic ).each do |type|
      Card.search(type: type).each(&:update_contribution_count)
    end
  end
end
