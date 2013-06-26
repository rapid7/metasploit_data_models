# @note All options not specific to any given rake task should go in the .yardopts file so they are available to both
#   the below rake tasks and when invoking `yard` from the command line

if defined? YARD
  namespace :yard do
    YARD::Rake::YardocTask.new(:doc) do |t|
      # --no-stats here as 'stats' task called after will print fuller stats
      t.options = ['--no-stats']

      t.after = Proc.new {
        Rake::Task['yard:stats'].execute
      }
    end

    desc "Shows stats for YARD Documentation including listing undocumented modules, classes, constants, and methods"
    task :stats => :environment do
      stats = YARD::CLI::Stats.new
      stats.run('--compact', '--list-undoc')

      undocumented_count = stats.instance_variable_get(:@undocumented)

      if undocumented_count > 0
        # flush so that fail's error occurs after normal output
        $stdout.flush
        $stderr.flush

        object = 'object'.pluralize(undocumented_count)
        fail "#{undocumented_count} #{object} are undocumented.  " \
             "Document the objects in Undocumented Objects list above for `rake yard` to pass (exit with 0)."
      end
    end
  end

  # @todo Figure out how to just clone description from yard:doc
  desc "Generate YARD documentation"
  # allow calling namespace to as a task that goes to default task for namespace
  task :yard => ['yard:doc']
end