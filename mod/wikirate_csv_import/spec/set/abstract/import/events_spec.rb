RSpec.describe Card::Set::Abstract::Import do
  let(:new_file_card_name) { "live import" }
  let(:old_file_card) { Card["answer import test"] }

  describe "event: generate_import_map" do
    it "uses automapping to generate an initial map" do
      create_import_file
      im = Card[new_file_card_name].import_map_card
      expect(im.id).to be_positive
      expect(im.content).to eq(old_file_card.import_map_card.content)
    end
  end

  describe "event: generate_import_status" do
    it "uses validation to generate an initial status" do
      create_import_file
      is = Card[new_file_card_name].import_status_card
      expect(is.id).to be_positive
      puts old_file_card.import_status_card.content
      puts is.content
      expect(is.content).to eq(old_file_card.import_status_card.content)
    end
  end

  describe "event: disallow_content_update" do
    it "raises an error if you try to update content" do
      expect { old_file_card.update! content: "whatever" }
        .to raise_error(/updates to import files are not allowed/)
    end
  end

  describe "event: mark_items_as_importing" do
    it "immediately marks items in progress as 'importing'" do
      Delayed::Worker.delay_jobs = true
      # status should remain "importing" until delayed job is processed
      importing_items 8 do
        old_file_card.update({})
        expect(refreshed_status.item_hash(8)[:status]).to eq(:importing)
      end
    end
  end

  describe "event: initiate import" do
    it "imports valid rows" do
      importing_items 8 do
        old_file_card.update({})
        expect(refreshed_status.item_hash(8)[:status]).to eq(:success)
      end
    end
  end

  describe "event: initiate import" do
    it "fails on invalid rows" do
      importing_items 1 do
        old_file_card.update({})
        expect(refreshed_status.item_hash(1)[:status]).to eq(:not_ready)
      end
    end
  end

  describe "event: initiate import" do
    it "imports valid rows even after a failure" do
      importing_items 1, 8 do # 1 is not ready, 8 is valid (see above)
        old_file_card.update({})
        expect(refreshed_status.item_hash(8)[:status]).to eq(:success)
      end
    end
  end

  private

  def refreshed_status
    old_file_card.import_status_card.refresh(true).status
  end

  def importing_items *indeces
    Card::Env.params[:import_rows] = indeces.each_with_object({}) do |i, h|
      h[i] = true
    end
    yield
  end

  def create_import_file
    Card.create name: new_file_card_name,
                type: :answer_import_file,
                answer_import_file: SharedData.csv_file("answer_import")
  end
end
