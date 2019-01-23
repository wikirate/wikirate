RSpec.describe Card::Set::Right::CheckedBy do
  let(:answer_card) { Card["joe_user+RM+death_star+1977"] }

  let(:checked_by_card) { Card["joe_user+RM+death_star+1977"].checked_by_card }

  def check_value
    Card::Env.params["set_flag"] = "checked"
    cb_card = answer_card.checked_by_card
    cb_card.save!
    cb_card.clear_subcards # why?
    cb_card.update! subcards: {} # why?
    Card::Env.params.delete "set_flag"
  end

  def with_badge binding, num
    binding.with_tag :h5 do
      with_tag "span.badge", /#{num}/
    end
  end

  describe "view :core" do
    subject(:core) { checked_by_card.format.render_core }

    context "when nobody checked" do
      example "creator", with_user: "WikiRate Bot" do
        expect(core).to have_tag :div do
          with_badge self, 0
          with_text /Nobody has checked this value since it was created/
          without_text "checked this value"
          without_tag :button
        end
      end

      example "other user" do
        expect(core).to have_tag :div do
          with_badge self, 0
          with_text /Nobody has checked this value since it was created/
          without_text "checked this value"
          with_tag :button, "Yes, I checked"
          with_tag :a, "No, I'll fix it"
        end
      end

      context "when value was updated" do
        before do
          with_user "John" do
            answer_card.value_card.update content: "200"
          end
        end

        example "creator", with_user: "Wikirate Bot" do
          expect(core).to have_tag :div do
            with_badge self, 0
            with_text /Nobody has checked this value since it was last updated/
            without_text "checked this value"
            with_tag :button, "Yes, I checked"
            with_tag :a, "No, I'll fix it"
          end
        end

        example "updater", with_user: "John" do
          expect(core).to have_tag :div do
            with_badge self, 0
            with_text /Nobody has checked this value since it was last updated/
            without_text "checked this value"
            without_tag :button
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

      example "creator", with_user: "WikiRate Bot" do
        expect(core).to have_tag :div do
          with_badge self, 1
          with_tag :a, "John"
          with_text /checked this value/
          without_tag :button
        end
      end

      example "checker", with_user: "John" do
        expect(core).to have_tag :div do
          with_badge self, 1
          with_tag :a, "John"
          with_text /checked this value/
          with_tag :button, "Uncheck"
        end
      end

      example "other user" do
        expect(core).to have_tag :div do
          with_badge self, 1
          with_tag :a, "John"
          with_text /checked this value/
          with_tag :button, "Yes, I checked"
          with_tag :a, "No, I'll fix it"
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
          with_tag :button, "Uncheck"
        end
      end
    end
  end

  describe "check value" do
    before do
      check_value
    end

    let(:double_checked) do
      Card.fetch("Joe User", :double_checked).content
    end
    let(:checked_by) do
      answer_card.fetch trait: :checked_by
    end

    it "checks the metric value" do
      expect(checked_by.item_names.size).to eq(1)
      expect(checked_by.item_names).to include("Joe User")
    end

    it "is added to user's +double_checked card" do
      expect(double_checked).to include("[[#{answer_card.name}]]")
    end

    it "updates the answers table" do
      expect(answer_card.answer.checkers).to eq("Joe User")
    end

    context "value updated" do
      before do
        answer_card.value_card.update content: "200"
      end

      it "clears double checked status" do
        expect(checked_by.content).to eq ""
      end
    end
  end

  describe "uncheck value" do
    subject(:cb_card) do
      cb_card = answer_card.fetch trait: :checked_by,
                                  new: { content: "[[Joe User]]" }
      cb_card.save!
      cb_card.clear_subcards
      cb_card.update! subcards: {}
      cb_card
    end

    before do
      Card::Env.params["set_flag"] = "not-checked"
    end

    it "checks the metric value" do
      expect(cb_card.item_names.size).to eq(0)
    end

    it "updates the answers table" do
      expect(answer_card.answer.checkers).to eq(nil)
    end
  end
end
