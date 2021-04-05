# -*- encoding : utf-8 -*-

class AddContributionTasks < Cardio::Migration
  def up
    merge_cards %w[
      add_a_company_logo
      add_a_company_logo+icon
      add_a_company_logo+description
      add_a_company_logo+why
      add_a_company_logo+how_to
      add_a_company_logo+search
      add_an_open_corporate_mapping
      add_an_open_corporate_mapping+description
      add_an_open_corporate_mapping+why
      add_an_open_corporate_mapping+how_to
      add_an_open_corporate_mapping+search
      add_wikipedium_information
      add_wikipedium_information+description
      add_wikipedium_information+why
      add_wikipedium_information+how_to
      add_wikipedium_information+search
      review_a_flagged_answer
      review_a_flagged_answer+icon
      review_a_flagged_answer+description
      review_a_flagged_answer+why
      review_a_flagged_answer+how_to
      review_a_flagged_answer+search
      source_without_a_file
      source_without_a_file+description
      source_without_a_file+why
      source_without_a_file+how_to
      source_without_a_file+search
      topic_without_an_image
      topic_without_an_image+search
    ]
  end
end
