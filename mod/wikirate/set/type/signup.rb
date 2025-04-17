card_accessor :newsletter, type: :pointer
card_accessor :profile_type, type: :pointer

format :html do
  before :content_formgroups do
    voo.edit_structure = [
      [:profile_type, { title: "Profile Type" }],
      [:newsletter, { title: "Newsletter" }]
    ]
  end
end
