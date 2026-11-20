# frozen_string_literal: true

# Every example keeps the base forms it asks for in a folder of its own
# process, emptied after it, so none reaches the developer's own.
RSpec.configure do |config|
  lemmas_dir = Rails.root.join("tmp/spec/lemmas-store-#{Process.pid}")

  config.before { stub_const("Lemmas::DIR", lemmas_dir) }
  config.after { FileUtils.rm_rf(lemmas_dir) }
end
