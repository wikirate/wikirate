RSpec.describe Card::Set::Abstract::Import::Events do
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
      # status should remain "importing" until delayed job is processed
      expect(import_status_for(8, work_off: false)).to eq(:importing)
    end
  end

  describe "event: initiate import" do
    it "imports valid rows" do
      expect(import_status_for(8)).to eq(:success)
    end

    it "fails on invalid rows" do
      expect(import_status_for(1)).to eq(:not_ready)
    end

    context "when item has failed previously" do
      it "imports valid rows even after a failure" do
        expect(import_status_for(8, import_indeces: [1, 8])).to eq(:success)
      end
    end
  end

  private

  def import_status_for status_index, import_indeces: nil, work_off: true
    Delayed::Worker.delay_jobs = true
    import_indeces ||= [status_index]
    importing_items(*import_indeces, work_off) { old_file_card.update({}) }
    refreshed_status.item_hash(status_index)[:status]
  end

  def refreshed_status
    old_file_card.import_status_card.refresh(true).status
  end

  def importing_items *indeces, work_off
    row_hash = indeces.each_with_object({}) { |i, h| h[i] = true }
    Card::Env.with_params import_rows: row_hash do
      yield
      Delayed::Worker.new.work_off if work_off
    end
  end

  def create_import_file
    Card.create name: new_file_card_name,
                type: :answer_import,
                answer_import: SharedData.csv_file("answer_import")
  end
end
