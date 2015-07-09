card_accessor :contribution_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"

def update_direct_contribution_count
  new_contr_count = count
  Card::Auth.as_bot do
    if direct_contribution_count_card.new_card?
      direct_contribution_count_card.update_attributes!(:content => new_contr_count.to_s)
    else
      direct_contribution_count_card.update_column(:db_content, new_contr_count.to_s)
      direct_contribution_count_card.expire
    end
  end
end
