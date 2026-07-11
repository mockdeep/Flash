# frozen_string_literal: true

RSpec.describe FactoryBot do
  it "has valid factories" do
    # :card is abstract (its class can't satisfy the cards.type constraint);
    # only its typed sub-factories are meant to be created.
    factories = described_class.factories.reject { |f| f.name == :card }

    FactoryCache.disable do
      expect { described_class.lint(factories, traits: true, verbose: true) }
        .not_to raise_error
    end
  end
end
