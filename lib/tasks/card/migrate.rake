namespace :card do
  namespace :migrate do
    task deck_structure: :environment do
      Cardio.schema_mode(:deck) do
        ActiveRecord::Schema.assume_migrated_upto_version(
          "20170524163321", Cardio.migration_paths(:deck)
        )
      end
      migrate_deck_structure
    end
  end
end
