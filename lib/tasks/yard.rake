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

    task :doc => :environment

    task :erd => :environment do
      require 'rails_erd/diagram/graphviz'

      merged_options = MetasploitDataModels::EntityRelationshipDiagram::DEFAULT_OPTIONS.merge(
          :filename => 'doc/mdm.erd',
          :filetype => :svg,
          :title => 'Mdm (Direct) Entity-Relationship Diagram'
      )
      diagram = RailsERD::Diagram::Graphviz.new(
          MetasploitDataModels::EntityRelationshipDiagram.domain,
          merged_options
      )
      path = diagram.create

      File.open(path) do |svg|
        document = Nokogiri::XML(svg)

        File.open("#{path}.inline", 'w') do |inline|
          inline.puts document.root.serialize
        end
      end
    end

    task :doc => :erd

    desc "Shows stats for YARD Documentation including listing undocumented modules, classes, constants, and methods"
    task :stats => :environment do
      stats = YARD::CLI::Stats.new
      stats.run('--compact', '--list-undoc')
    end
  end

  # @todo Figure out how to just clone description from yard:doc
  desc "Generate YARD documentation"
  # allow calling namespace to as a task that goes to default task for namespace
  task :yard => ['yard:doc']

  task :default => :yard
else
  puts 'YARD not defined, so yard tasks cannot be setup.'
end