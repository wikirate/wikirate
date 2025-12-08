# event :store_attribution_snapshot, :integrate_with_delay,
#       priority: 90, on: :create do
#   snapshot_tmpfile do |tfile|
#     take_snapshot tfile
#     file_card.file = tfile
#     file_card.save!
#   end
# end

format :csv do
  view :titles do
    ::Answer.csv_titles true
  end
end

private

def snapshot_tmpfile
  f = Tempfile.new [id.to_s, ".csv"]
  yield f
  f.close
  f.unlink
end

def take_snapshot tfile
  each_snapshot_row do |row|
    tfile.puts ::CSV.generate_line(row)
  end
  tfile.close
end

def each_snapshot_row &block
  each_snapshot_header_row(&block)
  each_snapshot_answer_row(&block)
end

def each_snapshot_header_row
  format(:csv).render_header.each do |row|
    yield row
  end
end

def each_snapshot_answer_row
  subject.card.each_snapshot_row do |answer|
    yield answer.csv_line(true)
  end
end
