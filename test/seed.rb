# -*- encoding : utf-8 -*-
require 'timecop'

require_dependency 'card'

class SharedData
  class << self
    def account_args hash
      { '+*account' => { '+*password' => 'joe_pass' }.merge(hash) }
    end

    def add_wikirate_data
      Card::Cache.reset_global
      Card::Env.reset
      Card::Auth.as_bot
      add_companies_and_topics
      add_sources_and_claims
      add_metrics
    end

    def add_companies_and_topics
      Card.create! name: 'Death Star', type: 'company',
                   subcards: {
                     '+about' => { content: 'Judge me by my size, do you?' }
                   }
      Card.create! name: 'Force', type: 'topic',
                   subcards: {
                     '+about' => {
                       content: 'A Jedi uses the Force for ' \
                                'knowledge and defense, never for attack.'
                     }
                   }
      Card.create! name: 'Death Star+Force', type: 'analysis',
                   subcards: {
                     '+article' => { content: "I'm your father!" }
                   }
    end

    def add_sources_and_claims
      sourcepage = Card.create!(
        type_id: Card::SourceID,
        subcards: {
          '+Link' => { content: 'http://www.wikiwand.com/en/Star_Wars' },
          '+company' => { content: '[[Death Star]]', type_id: Card::PointerID },
          '+topic' => { content: '[[Force]]', type_id: Card::PointerID }
        }
      )
      Card.create!(
        name: 'Death Star uses dark side of the Force',
        type_id: Card::ClaimID,
        subcards: {
          '+source' => {
            content: "[[#{sourcepage.name}]]", type_id: Card::PointerID
          },
          '+company' => {
            content: '[[Death Star]]',         type_id: Card::PointerID
          },
          '+topic' => {
            content: '[[Force]]',              type_id: Card::PointerID
          }
        }
      )
    end

    def add_metrics
      Card::Env[:protocol] = 'http://'
      Card::Env[:host] = 'wikirate.org'
      Card.create! name: '1977', type_id: Card::YearID
      Card::Metric.create name: 'Jedi+disturbances in the Force',
                          value_type: 'Category',
                          value_options: %w(yes no) do
        Death_Star '1977' => { value: 'yes',
                               source: 'http://wikiwand.com/en/Death_Star' }
      end
      Card::Metric.create name: 'Jedi+deadliness', value_type: 'Number' do
        source_link = 'http://wikiwand.com/en/Return_of_the_Jedi'
        Death_Star '1977' => { value: 100, source: source_link }
      end
      Card::Metric.create name: 'Jedi+cost of planets destroyed',
                          value_type: 'Currency' do
        source_link = 'http://wikiwand.com/en/Return_of_the_Jedi'
        Death_Star '1977' => { value: 200, source: source_link }
      end
      Card::Metric.create name: 'Jedi+friendliness',
                          type: :formula,
                          formula: '1/{{Jedi+deadliness}}'
      Card::Metric.create name: 'Jedi+deadliness+Joe User',
                          type: :score,
                          formula: '{{Jedi+deadliness}}/10'
      Card::Metric.create name: 'Jedi+deadliness+Joe Camel',
                          type: :score,
                          formula: '{{Jedi+deadliness}}/20'
      Card::Metric.create name: 'Jedi+disturbances in the Force+Joe User',
                          type: :score,
                          formula: { yes: 10, no: 0 }
      Card::Metric.create(
        name: 'Jedi+darkness rating',
        type: :wiki_rating,
        formula: { 'Jedi+deadliness+Joe User' => 60,
                   'Jedi+disturbances in the Force+Joe User' => 40 }
      )

      Card::Metric.create name: 'Joe User+score1', type: :researched,
                          random_source: true do
        Samsung          '2014' => 10, '2015' => 5
        Sony_Corporation '2014' => 1
        Death_Star       '1977' => 5
      end
      Card::Metric.create name: 'Joe User+score2', type: :researched,
                          random_source: true do
        Samsung          '2014' => 5, '2015' => 2
        Sony_Corporation '2014' => 2
      end
      Card::Metric.create name: 'Joe User+score3', type: :researched,
                          random_source: true do
        Samsung '2014' => 1, '2015' => 1
      end

      # Card::Metric.create name: 'Joe User+score1', type: :score,
      #                     random_source: true do
      #   Samsung          '2014' => 10, '2015' => 5
      #   Sony_Corporation '2014' => 1
      #   Death_Star       '1977' => 5
      # end
      # Card::Metric.create name: 'Joe User+score2', type: :score,
      #                     random_source: true do
      #   Samsung          '2014' => 5, '2015' => 2
      #   Sony_Corporation '2014' => 2
      # end
      # Card::Metric.create name: 'Joe User+score3', type: :score,
      #                     random_source: true do
      #   Samsung '2014' => 1, '2015' => 1
      # end
    end
  end
end
