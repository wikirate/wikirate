namespace :wikirate do
  namespace :company_group do
    task update_large_lists: :environment do
      Card::CompanyGroup.update_large_lists
    end
  end
end
