# frozen_string_literal: true

FAKE_ID = "__fake_id__"

def record_double(klass, **method_overrides)
  fake_record = klass.new
  method_overrides.reverse_merge!(id: FAKE_ID)

  mock_methods(fake_record, method_overrides)

  RSpec::Mocks
    .expect_message(klass, :find_by, expected_from: expected_from)
    .with(id: FAKE_ID)
    .at_least(:once)
    .and_return(fake_record)

  fake_record
end

def mock_methods(fake_record, method_overrides)
  method_overrides.each do |method_name, return_value|
    RSpec::Mocks
      .expect_message(fake_record, method_name, expected_from: expected_from)
      .at_least(:once)
      .and_return(return_value)
  end
end

def expected_from
  caller.find { |line| line.exclude?(__FILE__) }
end
