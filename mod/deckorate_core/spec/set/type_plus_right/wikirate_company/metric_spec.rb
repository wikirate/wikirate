# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Metric do
  it_behaves_like "cached count", "Death Star+metric", metric_count, 1 do
    let :add_one do
      Card["Joe User+researched number 2"].create_answers true do
        Death_Star "1977" => 5
      end
    end
    let :delete_one do
      Card["Jedi+Victims by Employees+Death Star+1977"].delete
    end
  end
end
