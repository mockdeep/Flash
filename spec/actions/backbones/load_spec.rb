# frozen_string_literal: true

RSpec.describe Backbones::Load do
  def owner
    User.find_or_create_by!(username: "ana") do |user|
      user.assign_attributes(attributes_for(:user, username: "ana"))
    end
  end

  # The backbone is set up (the fixture's copy, by default) before loading.
  def load(_prepared = tale_backbone)
    owner
    described_class.call("tale", "ana")
  end

  def headed(backbone, code, chapter, title = "Casa")
    level = backbone.level(code)
    backbone.save_heading(level, chapter, title:, translation: "House")
    backbone
  end

  def original_source
    {
      title_translation: "The Tale",
      author: "Ana Autora",
      license: "public_domain",
      source_url: "https://example.com/conto",
    }
  end

  def source(title = "O Conto") = owner.sources.find_by!(title:)

  describe ".call" do
    it "adds each version's written and headed chapters" do
      expect(load.first).to eq("O Conto: added I, II")
    end

    it "makes a source for the original" do
      load

      expect(source).to have_attributes(original_source)
    end

    it "gives the source the work's language" do
      load

      expect(source.language.code).to eq("pt")
    end

    it "makes a source for a level, named for it" do
      load(headed(tale_backbone, "B1", "I"))

      expect(source("O Conto — Nível B1").title_translation)
        .to eq("The Tale — Level B1")
    end

    it "gives a level's source the retellings' license" do
      load(headed(tale_backbone, "B1", "I"))

      expect(source("O Conto — Nível B1"))
        .to have_attributes(license: "cc_by_sa", source_url: nil)
    end

    it "heads each snippet with its number and title" do
      load
      snippet = source.snippets.first

      expect([snippet.heading, snippet.heading_translation])
        .to eq(["I — Um", "I — One"])
    end

    it "gives each snippet its chapter's text" do
      load

      expect(source.snippets.second.body).to eq("A casa.")
    end

    it "adds the chapters in reading order" do
      load

      expect(source.snippets.map(&:heading)).to eq(["I — Um", "II — Dois"])
    end

    it "makes no source for a version with nothing ready" do
      expect(load.second).to eq("O Conto — Nível B1: nothing to add")
    end

    it "stops at a chapter without its heading" do
      backbone = headed(tale_backbone, "A1", "II")

      expect(load(backbone).last).to eq("O Conto — Nível A1: nothing to add")
    end

    it "stops at a chapter not yet written" do
      backbone = headed(headed(tale_backbone, "B1", "I"), "B1", "II")

      expect(load(backbone).second).to eq("O Conto — Nível B1: added I")
    end

    it "adds nothing it has already added" do
      load

      expect(load.first).to eq("O Conto: nothing to add")
    end

    it "adds the chapters after those it has added" do
      backbone = headed(tale_backbone, "A1", "I")
      load(backbone)

      expect(load(headed(backbone, "A1", "II")).last)
        .to eq("O Conto — Nível A1: added II")
    end

    it "raises when a source can't be made" do
      create(:word_list, user: owner, name: "O Conto", language: "pt")

      expect { load }.to raise_error(described_class::Failed, /Title/)
    end

    it "raises when a snippet can't be made" do
      backbone = tale_backbone
      backbone.original_path("II").write("")

      expect { load(backbone) }.to raise_error(described_class::Failed)
    end
  end
end
