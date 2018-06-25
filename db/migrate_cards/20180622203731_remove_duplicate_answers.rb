# -*- encoding : utf-8 -*-

class RemoveDuplicateAnswers < Card::Migration
  def up
    ENV["SKIP_UPDATE_RELATED"] = true
    duplicates.each do |dup|
      wipe_duplicate dup
      if researched?(dup)
        refresh_researched(dup)
      else
        refresh_calculated(dup)
      end
    end
  end

  def researched? dup
    Card[dup.metric_id].researched?
  end

  def refresh_researched dup
    Answer.create! card(dup)
  end

  def card dup
    Card.fetch dup.metric_id, dup.company_id, dup.year.to_s
  end

  def refresh_calculated dup
    card(dup)&.delete!
    Card[dup.metric_id].update_value_for! company: dup.company_id, year: dup.year
  end

  def duplicates
    Answer.select(:company_id, :metric_id, :year)
        .group(:company_id, :metric_id, :year)
        .having("count(*) > 1")
  end

  def wipe_duplicate dup
    Answer.where(
      company_id: dup.company_id,
      metric_id: dup.metric_id,
      year: dup.year
    ).destroy_all
  end
end
