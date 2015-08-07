# -*- encoding : utf-8 -*-
describe Card::Set::Right::TypeSearch do
  describe "filter_and_sort view" do
    context "topic" do
      it "show filter_and_sort items" do
        topic = get_a_sample_topic
        company = get_a_sample_company
        claim = create_claim "death is a joke", {"+company"=>{:content=>"[[#{company.name}]]"},"+topic"=>{:content=>"[[#{topic.name}]]"}}
        
        type_search_card = Card.fetch "#{topic.name}+company+type_search"
        html = type_search_card.format.render_filter_and_sort
        
        expect(html).to have_tag("div",:with=>{:class=>"yinyang-list"}) do
          with_tag("div",:with=>{:class=>"yinyang-row","data-sort-name"=>"DEATH STAR"}) do
            with_tag "div",:with=>{:id=>"Force+Death_Star+yinyang_drag_item"}
          end
        end
      end
    end
    context "metric" do
      it "show filter_and_sort items" do
        metric = get_a_sample_metric
        company = get_a_sample_company
        # binding.pry
        type_search_card = Card.fetch "#{metric.name}+company+type_search"
        html = type_search_card.format.render_filter_and_sort
        
        expect(html).to have_tag("div",:with=>{:class=>"yinyang-list"}) do
          with_tag("div",:with=>{:class=>"yinyang-row"}) do
            with_tag "div",:with=>{:id=>"Jedi+disturbances_in_the_Force+Death_Star+yinyang_drag_item"}
            with_tag "div",:with=>{:id=>"Jedi+disturbances_in_the_Force+Sample_Company+yinyang_drag_item"}
          end
        end
      end
    end
  end
end