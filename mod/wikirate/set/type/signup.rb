card_accessor :newsletter, type: :pointer
card_accessor :profile_type, type: :pointer

format :html do
  before :content_formgroups do
    voo.edit_structure = %i[newsletter profile_type]
  end
end
