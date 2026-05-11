# frozen_string_literal: true

RSpec.describe FactoryBot do
  it "has valid factories" do
    FactoryCache.disable do
      expect { described_class.lint(traits: true, verbose: true) }
        .not_to raise_error
    end
  end
end
