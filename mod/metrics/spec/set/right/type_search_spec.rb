# -*- encoding : utf-8 -*-

describe Card::Set::Right::TypeSearch do
  describe "filter_and_sort view" do
    context "topic" do
      it "show filter_and_sort items" do
        topic = sample_topic
        company = sample_company
        create_claim "death is a joke",
                     "+company" => { content: "[[#{company.name}]]" },
                     "+topic"   => { content: "[[#{topic.name}]]"   }

        type_search_card = topic.fetch trait: [:wikirate_company, :type_search]
        html = type_search_card.format.render_filter_and_sort

        expect(html).to have_tag("div", with: { class: "yinyang-list" }) do
          with_tag("div", with: { :class => "yinyang-row",
                                  "data-sort-name" => "DEATH STAR" }) do
            with_tag "div", with: { id: "Force+Death_Star+yinyang_drag_item" }
          end
        end
      end
    end

    context "metric" do
      it "show filter_and_sort items" do
        # default sample metric is free text
        metric = sample_metric
        type_search_card = metric.fetch trait: [:wikirate_company, :type_search]
        html = type_search_card.format.render_filter_and_sort
        id = "Jedi+Sith_Lord_in_Charge+Death_Star+yinyang_drag_item"
        expect(html).to have_tag("div", with: { class: "yinyang-list" }) do
          with_tag("div", with: { class: "yinyang-row" }) do
            with_tag "div", with: { id: id }
          end
        end
      end
    end
  end
end
