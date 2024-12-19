namespace :wikirate do
  namespace :mel do
    task record: :environment do
      Wikirate::MEL.record
    end
  end
end
