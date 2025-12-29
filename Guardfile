# frozen_string_literal: true

group :everything, halt_on_fail: true do
  rspec_options = {
    all_after_pass: false,
    all_on_start: false,
    failed_mode: :keep,
    cmd: "rspec",
  }

  guard :rspec, rspec_options do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new(self)

    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)

    rails = dsl.rails
    dsl.watch_spec_files_for(rails.app_files)
    dsl.watch_spec_files_for(rails.views)

    watch(rails.controllers) do |m|
      [
        rspec.spec.call("controllers/#{m[1]}_controller"),
      ]
    end

    watch(rails.spec_helper)     { rspec.spec_dir }
    watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }

    watch(rails.view_dirs)     { |m| rspec.spec.call("features/#{m[1]}") }
    watch(rails.layouts)       { |m| rspec.spec.call("features/#{m[1]}") }
  end

  guard :rubocop, all_on_start: false, cli: ["-a", "--display-cop-names"] do
    watch(/.+\.rb$/)
    watch(%r{bin/*})
    watch(/Guardfile/)
    watch(/Rakefile/)
    watch(/.+\.rake$/)
    watch(/.+\.ru$/)
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end
