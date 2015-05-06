# -*- encoding : utf-8 -*-

class ImportMoreMetricStuff < Card::Migration
  def up
    Card.create! :name=>'*novotes', :codename=>'novotes'
    Card.create! :name=>'upvotee search', :type_id=>'search', :codename=>'upvotee_search'
    Card.create! :name=>'downvotee search', :type=>'search', :codename=>'downvotee_search'
    Card.create! :name=>'novotee search', :type=>'search', :codename=>'novotee_search'
    Card.create! :name=>'type search', :type=>'search', :codename=>'type_search'
    Card.create! :name=>'upvotee search+*right+*default', :type_id=>Card::SearchTypeID
    Card.create! :name=>'downvotee search+*right+*default',:type_id=>Card::SearchTypeID
    Card.create! :name=>'novotee search+*right+*default', :type_id=>Card::SearchTypeID
    Card.create! :name=>'type search+*right+*default', :type_id=>Card::SearchTypeID
    ['votee search', 'non-votee search'].each do |name|
      fe = Card.fetch name
      fe.update_attributes! :codename=>nil
      fe.delete
    end
    import_json "more_metric_stuff.json"

  end
end
