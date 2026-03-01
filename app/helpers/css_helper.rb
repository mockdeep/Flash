# frozen_string_literal: true

module CssHelper
  BUTTON_MODIFIERS = [
    :compact,
    :primary,
    :ghost,
    :secondary,
    :danger,
    :disabled,
  ].freeze

  def button_class(*modifiers)
    unknown = modifiers - BUTTON_MODIFIERS

    if unknown.any?
      names = unknown.map(&:inspect).join(", ")
      raise ArgumentError, "Unknown button modifier(s): #{names}"
    end

    tokens = ["button"]
    modifiers.each { |mod| tokens << "button--#{mod}" }
    tokens.join(" ")
  end
end
