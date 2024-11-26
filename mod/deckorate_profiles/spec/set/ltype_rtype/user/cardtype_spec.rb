RSpec.describe Card::Set::LtypeRtype::User::Cardtype do
  describe "view :contribution_report" do
    def card_subject
      Card.fetch "Joe User", :answer
    end

    def report_url report
      "/#{card_subject.name.url_key}/contribution_report?report_tab=#{report}"
    end

    describe "view: contribution_report" do
      example "without current_tab" do
        expect_view(:contribution_report)
          .to have_tag "div.card-slot.answer-contribution-report" do
          with_tag ".contribution-report-header" do
            with_tag "ul.nav.nav-tabs" do
              with_tag "li.contribution-report-title-box" do
                with_tag :a, with: { href: report_url(:badges) } do
                  with_tag "h5.contribution-report-title", "Answers"
                end
              end
              with_tag "li.contribution-report-box.nav-item" do
                with_tag :a, with: { href: report_url(:created) } do
                  with_tag "span.badge-label", "Created"
                  with_tag "span.badge-count", "7"
                end
              end
              with_tag "li.contribution-report-toggle.text-center.nav-item" do
                with_tag :a, with: { href: report_url(:created) }
              end
            end
          end
        end
      end

      example "with current_tab" do
        Card::Env.with_params report_tab: :created do
          expect_view(:contribution_report).to lack_errors
        end
      end
    end
  end
end
