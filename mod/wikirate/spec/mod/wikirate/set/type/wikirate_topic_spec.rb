describe Card::Set::Type::WikirateTopic do
  it "shows the link for view \"missing\"" do
    
    html = render_card :missing,{:type=>"topic",:name=>"test"}
    expect(html).to eq(render_card :link,{:type=>"topic",:name=>"test"} )
  end
end