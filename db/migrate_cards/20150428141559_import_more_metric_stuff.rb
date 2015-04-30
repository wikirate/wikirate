# -*- encoding : utf-8 -*-

class ImportMoreMetricStuff < Card::Migration
  def up
    Card.create! :name=>'upvotee search', :type=>'search', :codename=>'upvotee_search'
    Card.create! :name=>'downvotee search', :type=>'search', :codename=>'downvotee_search'
    Card.create! :name=>'novotee search', :type=>'search', :codename=>'novotee_search'
    Card.create! :name=>'type search', :type=>'search', :codename=>'type_search'
    ['votee search', 'non-votee search'].each do |name|
      fe = Card.fetch name
      fe.update_attributes! :codename=>nil
      fe.delete
    end
    import_json "more_metric_stuff.json"

  end
end
