# -*- encoding : utf-8 -*-

class FeaturedCards < Cardio::Migration
  SPLIT = {
    companies: :wikirate_company,
    projects: :project,
    topics: :wikirate_topic,
    answers: :metric_answer,
  }
  def up
    SPLIT.each do |old_code, new_left|
      Card[:"homepage_featured_#{old_code}"].update! codename: nil,
                                                     name: [new_left, :featured]
    end
  end
end
