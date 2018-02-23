describe Card::Set::Abstract::Listing do
  let(:research_group_format) do
    Card["Jedi"].format :html
  end

  describe "#listing" do
    subject do
      research_group_format.render :listing
    end

    it "includes left, middle, and right" do
      is_expected.to have_tag "div.listing" do
        with_tag "div.listing-left" do
          with_tag "div.thumbnail"
        end
        with_tag "div.listing-middle" do
          with_tag "span.badge"
        end
        with_tag "div.listing-right" do
          with_tag "span.badge"
        end
      end
    end
  end

  describe "#expanded_listing" do
    subject do
      research_group_format.render :expanded_listing
    end

    it "includes top(left and right) and bottom" do
      is_expected.to have_tag "div.expanded-listing" do
        with_tag "div.listing-top" do
          with_tag "div.listing-left" do
            with_tag "div.thumbnail"
          end
          with_tag "div.listing-right" do
            with_tag "span.badge"
          end
        end
        with_tag "div.listing-bottom" do
          with_tag "span.badge"
        end
      end
    end
  end
end
