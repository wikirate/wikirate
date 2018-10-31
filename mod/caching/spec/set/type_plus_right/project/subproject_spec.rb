# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Project::Subproject do
  it_behaves_like "cached count", "Evil Project+subproject", 1, 1 do
    let :add_one do
      Card.create! name: "Daughter of Evil Project",
                   type_id: Card::ProjectID, subfields: { parent: "Evil Project" }
    end
    let :delete_one do
      Card["Son of Evil Project"].delete
    end
  end
end
