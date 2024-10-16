# -*- encoding : utf-8 -*-

# describe Card::Set::Right::Company do
#   before do
#     login_as "joe_user"
#   end
#   it "creates company card(s) while creating +companies card(s)" do
#     Card.create! name: "Lefty",
#                  subcards: { "+Company" => { content: "[[zzz]]\n[[xxx]]",
#                                              type: "pointer" } }
#     expect(Card.exist?("zzz")).to be true
#     expect(Card.exist?("xxx")).to be true
#     expect(Card["zzz"].type_id).to eq Card::CompanyID
#     expect(Card["xxx"].type_id).to eq Card::CompanyID
#   end
# end
