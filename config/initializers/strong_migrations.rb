# frozen_string_literal: true

StrongMigrations.lock_timeout = 10.seconds
StrongMigrations.lock_timeout_retries = 3
StrongMigrations.statement_timeout = 1.hour
StrongMigrations.safe_by_default = true
