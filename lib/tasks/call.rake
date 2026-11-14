# frozen_string_literal: true

desc("Call an action, printing the lines it returns: call[Name,arg,…]")
task(:call, [:callable] => :environment) do |_task, args|
  puts(args[:callable].constantize.call(*args.extras))
end
