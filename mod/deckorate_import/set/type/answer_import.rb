include_set Type::File
include_set Abstract::WikirateImport

# following shouldn't be necessary.  handle in Abstract::Import
attachment :answer_import, uploader: CarrierWave::FileCardUploader

def db_content= content
  raise "blank answer import file!!" if content.blank?

  super
end

def import_item_class
  AnswerImportItem
end
