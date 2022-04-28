require "colorize"

# namespace :wikirate do
#   namespace :test do
#     full_dump_path = File.join Decko.root, "db", "test_seed.db"
#
#     def testdb
#       @testdb ||= ENV["DATABASE_NAME_TEST"] ||
#                   ((t = Decko.config.database_configuration["test"]) &&
#                   t["database"])
#     end
#
#     def execute_command cmd, env=nil
#       cmd = "bundle exec #{cmd}"
#       cmd = "env RAILS_ENV=#{env} #{cmd}" if env
#       puts cmd.green
#       system cmd
#     end
#
#     def ensure_env env, task, args=nil
#       if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"].to_sym != env.to_sym
#         puts "restart task in #{env} environment"
#         task = "#{task}\\[#{args.to_a.join(',')}\\]" if args.to_a.present?
#         execute_command "rake #{task}", env
#       elsif block_given?
#         yield
#       end
#     end
#
#     def with_env_var key, value
#       old_val = ENV[key]
#       ENV[key] = value
#       result = yield
#       old_val ? ENV[key] = old_val : ENV.delete(key)
#       result
#     end
#
#     def ensure_test_db
#       return if testdb
#       puts "no test database"
#       exit
#     end
#
#     desc "seed test database"
#     task seed: :load_dump
#
#     desc "load db dump into test db"
#     task :load_dump, [:path] do |_task, args|
#       dump_path = args[:path] || ARGV[1] || full_dump_path
#       load_dump dump_path, testdb
#     end
#
#     desc "dump test database"
#     task :dump, [:path] do |task, args|
#       ensure_env :test, task do
#         dump_path = args[:path] || full_dump_path
#         dump dump_path, testdb
#       end
#     end
#   end
# end
