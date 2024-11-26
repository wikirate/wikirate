namespace :wikirate do
  namespace :mel do
    task answer: :environment do
      Wikirate::MEL.dump
    end
  end
end
