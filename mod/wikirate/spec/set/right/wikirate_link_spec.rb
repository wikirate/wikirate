# # -*- encoding : utf-8 -*-

describe Card::Set::Right::Source do
  # now allowing these edits (leaving as comment until decision becomes permanent)
  #
  # before do
  #   login_as "joe_user"
  # end
  # it "should block changing the url for existing source" do
  #   # create the page with source
  #   url = "http://www.google.com/?q=wikiratesigh"
  #   Card::Env.params[:sourcebox] = "true"
  #   sourcepage = Card.create! type_id: Card::SourceID, subcards: { "+Link" => { content: url } }
  #   Card::Env.params[:sourcebox] = "false"
  #   # link card
  #   link_card = Card["#{sourcepage.name}+link"]
  #   link_card.content = "http://www.google.com/"
  #   expect(link_card.save).to be false
  #   expect(link_card.errors).to have_key(:link)
  #   expect(link_card.errors[:link]).to include("is not allowed to be changed.")
  # end
end
