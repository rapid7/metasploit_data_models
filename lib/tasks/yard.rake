# @note All options not specific to any given rake task should go in the .yardopts file so they are available to both
#   the below rake tasks and when invoking `yard` from the command line

load Metasploit::Model.root.join('lib', 'tasks', 'yard.rake')

if defined? YARD
  namespace :yard do
    begin
      require 'rails_erd/diagram/graphviz'
    rescue LoadError
      puts "Won't be able to generate Mdm Entity-Relationship Diagram"
    else
      namespace :erd do
        images_directory = 'docs/images'

        namespace :mdm do
          task :module => [:environment] do
            MetasploitDataModels::EntityRelationshipDiagram.create(
                :domain => MetasploitDataModels::EntityRelationshipDiagram::Module.domain,
                :filename => File.join(images_directory, 'mdm-module.erd'),
                :filetype => :png,
                :title => 'Mdm::Module (Direct) Entity-Relationship Diagram'
            )
          end
        end

        task :mdm => [:environment] do
          MetasploitDataModels::EntityRelationshipDiagram.create(
              :filename => File.join(images_directory, 'mdm.erd'),
              :filetype => :png,
              :title => 'Mdm (Direct) Entity-Relationship Diagram'
          )
        end
      end

      task :erd => ['erd:mdm', 'erd:mdm:module']
      task :doc => :erd
    end
  end

  task :default => :yard
else
  puts 'YARD not defined, so yard tasks cannot be setup.'
end