# frozen_string_literal: true

Dir[File.join(__dir__, "./matchers/*.rb")].each { |path| require path }

def have_error(expected_message)
  Matchers::HaveError.new(expected_message)
end

def have_flash(expected_type, expected_message)
  Matchers::HaveFlash.new(expected_type, expected_message)
end

def change_record(record, attribute)
  Matchers::ChangeRecord.new(record, attribute)
end

def delete_record(record)
  Matchers::DeleteRecord.new(record)
end

def make_database_queries
  Matchers::MakeDatabaseQueries.new
end

RSpec::Matchers.define_negated_matcher(:not_change, :change)
RSpec::Matchers.define_negated_matcher(:not_change_record, :change_record)
RSpec::Matchers.define_negated_matcher(:not_delete_record, :delete_record)
