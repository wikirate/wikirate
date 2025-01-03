namespace :wikirate do
  namespace :mel do
    namespace :record do
      task week: :environment do
        Wikirate::MEL.new(period: "1 week").record
      end

      task month: :environment do
        Wikirate::MEL.new(period: "1 month").record
      end

      task year: :environment do
        Wikirate::MEL.new(period: "1 year").record
      end
    end
  end
end
