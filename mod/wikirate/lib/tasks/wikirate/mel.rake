namespace :wikirate do
  namespace :mel do
    task record: :environment do
      Wikirate::MEL.dump
    end
  end
end
