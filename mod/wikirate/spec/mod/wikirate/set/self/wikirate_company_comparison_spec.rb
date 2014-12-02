# -*- encoding : utf-8 -*-
include ActionView::Helpers::TextHelper
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
        Card::Env.params[:topic] = @topics[0].to_name.key
        Card::Env.params["company1"] = @companies[0].to_name.key
        Card::Env.params["company2"] = @companies[1].to_name.key

        html = @comparision_card.format.render_core
        puts html
        expect(html).to have_tag('form', :with => { }) do
          with_tag "select", :with => { :name => "topic", :id => "topic" } do
            topic_options = @topics.map { |t| [t,t.to_name.key] }  
            with_option '-- Select Topic --', ''
            topic_options.each do |option|
              with_option  option[0], option[1], :selected=>option[1]==@topics[0].to_name.key
            end
          end
          # binding.pry
          with_tag "div", :with => { :id => "#{@topics[0].to_name.url_key}+image"}
          with_tag "a", :href => "/#{@topics[0].to_name.url_key}", :content => @topics[0]
          

          all_company_options = @companies.map do |company_name|
            label = company_name
            claim_count = Card.claim_counts "#{company_name.to_name.key}+#{Card[@topics[0]].key}"
            if claim_count > 0
              label = "#{company_name} -- #{ pluralize claim_count, 'claim' }"
            end 
            [ label, company_name.to_name.key ]
          end
          with_tag "select", :with => { :name => "company1", :id => "company1" } do
            with_option '-- Select Company 1 --', ''
            all_company_options.each do |option|
              with_option  option[0], option[1] ,:selected=>option[1]==@companies[0].to_name.key
            end
          end
          with_tag "select", :with => { :name => "company2", :id => "company2" } do
            with_option '-- Select Company 2 --', ''
            all_company_options.each do |option|
              with_option  option[0], option[1] ,:selected=>option[1]==@companies[1].to_name.key
            end
          end
          
        end
         expect(html).to have_tag("div",  :class => "left-side") do 
          with_tag "div", :with => { :id => "#{@companies[0].to_name.url_key}+#{@topics[0].to_name.url_key}" }
        end
        expect(html).to have_tag("div", :class => "right-side") do
          with_tag "div", :with => { :id => "#{@companies[1].to_name.url_key}+#{@topics[0].to_name.url_key}" }
        end
      end
     
    end
  end

end