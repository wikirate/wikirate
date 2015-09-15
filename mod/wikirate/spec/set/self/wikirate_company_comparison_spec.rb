# -*- encoding : utf-8 -*-

describe Card::Set::Self::WikirateCompanyComparison do
  before do
    login_as 'joe_user'
    @topics = Card.search :type_id=>Card::WikirateTopicID, :sort=>:name, :return=>:name
    @companies = Card.search :type_id=>Card::WikirateCompanyID, :sort=>:name, :return=>:name
    @comparision_card = Card["company_comparison"]
  end
  describe "core view" do
    context "when no param" do
      it "shows select lists" do

        html = @comparision_card.format.render_core

        expect(html).to have_tag('form', :with => { }) do
          with_tag "select", :with => { :name => "topic", :id => "topic" } do
            topic_options = @topics.map { |t| [t,t.to_name.key] }
            with_option '-- Select Topic --', ''
            topic_options.each do |option|
              with_option  option[0], option[1]
            end
          end

          all_company_options = @companies.map { |c| [c,c.to_name.key] }
          with_tag "select", :with => { :name => "company1", :id => "company1" } do
            with_option '-- Select Company 1 --', ''
            all_company_options.each do |option|
              with_option  option[0], option[1]
            end
          end
          with_tag "select", :with => { :name => "company2", :id => "company2" } do
            with_option '-- Select Company 2 --', ''
            all_company_options.each do |option|
              with_option  option[0], option[1]
            end
          end
        end
      end
    end
    context "when companies and topic selected" do
      it "compares companies" do
        topic_chosen = Card["Natural Resource Use"]
        company1 = Card["Apple Inc."]
        company2 = Card["Samsung"]
        Card::Env.params[:topic] = topic_chosen.key
        Card::Env.params["company1"] = company1.key
        Card::Env.params["company2"] = company2.key

        html = @comparision_card.format.render_core
        expect(html).to have_tag('form', :with => { }) do
          with_tag "select", :with => { :name => "topic", :id => "topic" } do
            topic_options = @topics.map { |t| [t,t.to_name.key] }
            with_option '-- Select Topic --', ''
            topic_options.each do |option|
              with_option  option[0], option[1], :selected=>option[1]==topic_chosen.to_name.key
            end
          end
          #comment because image are removed in test databases
          # with_tag "div", :with => { :id => "#{topic_chosen.to_name.url_key}+image"}
          with_tag "a", :href => "/#{topic_chosen.to_name.url_key}", :content => topic_chosen


          all_company_options = @companies.map do |company_name|
            label = company_name
            claim_count = Card.claim_counts "#{company_name.to_name.key}+#{topic_chosen.key}"
            if claim_count > 0
              label = "#{company_name} -- #{ pluralize claim_count, 'claim' }"
            end
            [ label, company_name.to_name.key ]
          end
          with_tag "select", :with => { :name => "company1", :id => "company1" } do
            with_option '-- Select Company 1 --', ''
            all_company_options.each do |option|
              with_option  option[0], option[1] ,:selected=>option[1]==company1.to_name.key
            end
          end
          with_tag "select", :with => { :name => "company2", :id => "company2" } do
            with_option '-- Select Company 2 --', ''
            all_company_options.each do |option|
              with_option  option[0], option[1] ,:selected=>option[1]==company2.to_name.key
            end
          end

        end

        analysis1_card = Card["#{company1.name}+#{topic_chosen.name}"]
        analysis2_card = Card["#{company2.name}+#{topic_chosen.name}"]
         expect(html).to have_tag("div",  :class => "left-side") do
          with_tag "div", :with => { :id => "#{analysis1_card.cardname.url_key}" }
        end
        expect(html).to have_tag("div", :class => "right-side") do
          with_tag "div", :with => { :id => "#{analysis2_card.cardname.url_key}" }
        end
      end

    end
  end

end