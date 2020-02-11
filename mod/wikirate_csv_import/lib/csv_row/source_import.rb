class CsvRow
  # To be used by CsvRow classes to handle source imports.
  # Expects an url in row[:source].
  # A hash in extra_data[:all][:source_map] is used to handle duplicates sources in
  # the same import act.
  module SourceImport
    def initialize row, index, import_manager=nil
      super
      unless @import_manager.extra_data(:all)[:source_map]
        @import_manager.add_extra_data :all, source_map: {}
      end
      @source_map = @import_manager.extra_data(:all)[:source_map]
    end

    def source_args
      @source_args ||= @row
    end

    def source_subcard_args
      args = {
        "+File" => { remote_file_url: source_args[:source], type_id: Card::FileID }
      }
      # args["+title"] = { content: source_args[:title] } if source_args.key?(:title)
      # TODO: test if card get right type
      # (all pointer except title)
      [:title, :report_type, :company, :year].each do |name|
        next unless source_args.key? name
        args["+#{name}"] = { content: source_args[name] }
      end
      args
    end

    def import_source
      @source_map.fetch source_args[:source] do |url|
        source = create_or_update_source
        add_to_source_map url, source
        source
      end
    end

    def add_to_source_map url, source
      @import_manager.add_extra_data :all, source_map: { url => source }
    end

    def create_or_update_source
      duplicate = find_duplicate
      if duplicate.blank?
        create_source
      elsif @import_manager.conflict_strategy == :override
        resolve_source_duplication duplicate
      else
        duplicate
      end
    end

    def find_duplicate
      if refers_to_existing_source_name?
        Card[source_args[:source]]
      elsif source_args[:source].url?
        link_duplicates = Card::Set::Self::Source.find_duplicates source_args[:source]
        link_duplicates.present? && link_duplicates.first
      else
        error("source #{source_args[:source]} doesn't exist")
      end
    end

    def refers_to_existing_source_name?
      Card.fetch_type_id(source_args[:source]) == Card::SourceID
    end

    def resolve_source_duplication existing_source
      updated = false
      updated |= update_title_card existing_source
      updated |= update_existing_source existing_source
      skip(updated ? :overridden : :skipped)
    end

    def create_source
      pick_up_card_errors do
        add_card name: "",
                 type_id: Card::SourceID,
                 subcards: source_subcard_args,
                 skip: :requirements
        # finalize_source_card source_card
        # source_card
      end
    end

    def finalize_source_card source_card
      source_card.director.catch_up_to_stage :prepare_to_store

      # the pure source update doesn't finalize, don't know why
      return unless Card.exists?(source_card.name) && source_card.errors.empty?
      source_card.director.catch_up_to_stage :finalize
    end

    def update_existing_source source_card
      [:report_type, :company, :year].inject(false) do |updated, e|
        create_or_update_pointer_subcard(source_card, e, @row[e]) || updated
      end
    end

    def update_title_card source_card
      return if (field = source_card.field(:wikirate_title)) && field.content.present?
      # title_card = source_card.fetch :wikirate_title,
      #                                new: { content: @row[:title] }
      # return unless title_card.new?
      # add_subcard title_card
      add_card name: [source_card.name, :wikirate_title], content: @row[:title]
    end

    def create_or_update_pointer_subcard source_card, trait, content
      trait = hashkey_to_codename trait
      trait_card = source_card.fetch trait,
                                     new: { content: "[[#{content}]]" }
      if trait_card.new?
        add_card name: trait_card.name, content: trait_card.content
        # add_subcard trait_card
      elsif !trait_card.item_names.include?(content)
        trait_card.add_item! content
        # trait_card.add_item content
        # add_subcard trait_card
      else
        return false
      end
      true
    end

    def hashkey_to_codename key
      key == :company ? :wikirate_company : key
    end
  end

  def check_duplication_within_file
    return unless @source_map.key? source_args[:source]
    @import_manager.report :duplicate_in_file, source_args[:source]
    skip
  end
end
