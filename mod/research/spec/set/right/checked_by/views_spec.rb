RSpec.describe Card::Set::Right::CheckedBy::Views do
  let(:answer_card) { Card["joe_user+RM+death_star+1977"] }
  let(:checked_by_card) { Card["joe_user+RM+death_star+1977"].checked_by_card }

  def with_badge binding, num
    binding.with_tag(".labeled-badge") { with_tag "span.badge", /#{num}/ }
  end

  def check_value
    check_answer answer_card
  end

  describe "view :core" do
    subject(:core) { checked_by_card.format.render_core }

    context "when nobody checked" do
      example "creator", with_user: "Decko Bot" do
        expect(core).to have_tag :div do
          with_badge self, 0
          without_tag "a.btn"
        end
      end

      example "other user" do
        expect(core).to have_tag :div do
          with_badge self, 0
          with_tag :a, "I checked this answer"
        end
      end

      context "when value was updated" do
        before do
          with_user "John" do
            answer_card.value_card.update content: "200"
          end
        end

        example "creator", with_user: "Decko Bot" do
          expect(core).to have_tag :div do
            with_badge self, 0
            with_tag :a, "I checked this answer"
          end
        end

        example "updater", with_user: "John" do
          expect(core).to have_tag :div do
            with_badge self, 0
            with_tag "a._popover_link"
            without_tag "a.btn"
          end
        end
      end
    end

    context "when John checked" do
      before do
        with_user "John" do
          check_value
        end
      end

      example "creator", with_user: "Decko Bot" do
        expect(core).to have_tag :div do
          with_badge self, 1
          with_tag :a, "John"
          without_tag "a.btn"
        end
      end

      example "checker", with_user: "John" do
        expect(core).to have_tag :div do
          with_badge self, 1
          with_tag :a, "John"
          with_tag :a, "Uncheck"
        end
      end

      example "other user" do
        expect(core).to have_tag :div do
          with_badge self, 1
          with_tag :a, "John"
          with_tag :a, "I checked this answer"
        end
      end
    end

    context "with more than 3 users checked" do
      before do
        ["John", "Joe User", "Joe Camel", "Joe Admin"].each do |user|
          with_user user do
            check_value
          end
        end
      end

      example "checker", with_user: "Joe Admin" do
        expect(core).to have_tag :div do
          with_badge self, 4
          with_tag :a, "Joe Admin"
          with_text /John, Joe User, Joe Camel, and Joe Admin/
          with_tag :a, "Uncheck"
        end
      end
    end
  end
end
