# frozen_string_literal: true

module Helpers
  module BackboneHelpers
    def backbone_copies = Rails.root.join("tmp/spec/backbones-#{Process.pid}")

    # A copy of the fixture backbone, which an example may write to, with
    # its cache beside it.
    def tale_backbone
      unless backbone_copies.join("tale").exist?
        FileUtils.mkdir_p(backbone_copies)
        FileUtils.cp_r(file_fixture("backbones/tale"), backbone_copies)
      end
      stub_const("Backbone::ROOT", backbone_copies)
      stub_const("Backbone::CACHE", backbone_copies.join("cache"))

      Backbone.find("tale")
    end

    # The fixture backbone's word list for a level, holding these headwords.
    def tale_list(code, *headwords)
      name = "Tale #{code}"
      word_list = WordList.find_by(name:) ||
        create(:word_list, name:, language: "pt")
      headwords.each do |headword|
        entry = create(:entry, language: "pt", headword:)
        create(:sense_membership, word_list:, sense: create(:sense, entry:))
      end
    end

    # A lemma answer giving each form its own lower-case form, unless the
    # form (as a symbol) is given another answer.
    def lemma_answer(call, **given)
      words =
        JSON.parse(call.prompt).map do |item|
          form = item["form"]
          answer = { kind: "word", lemmas: [form.downcase], alternatives: [] }
          answer.merge(id: item["id"], **given.fetch(form.to_sym, {}))
        end
      { words: }
    end

    def lemma_call?(call) = call.model == Llm::SONNET
    def review_call?(call) = call.system.start_with?("You review")
  end
end

RSpec.configure do |config|
  config.include(Helpers::BackboneHelpers)
  config.after { FileUtils.rm_rf(backbone_copies) }
end
