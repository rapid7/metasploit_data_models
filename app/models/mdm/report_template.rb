# Template used to generate {Mdm::Report reports}.
# @todo https://www.pivotaltracker.com/story/show/52417783
class Mdm::ReportTemplate < ActiveRecord::Base
  #
  # Associations
  #

  # @!attribute [rw] workspace
  #   Workspace in which this report template was created.
  #
  #   @return [Mdm::Workspace]
  belongs_to :workspace, class_name: 'Mdm::Workspace', inverse_of: :report_templates

  #
  # Attributes
  #

  # @!attribute [rw] created_at
  #   When this report template was created.
  #
  #   @return [DateTime]

  # @!attribute [rw] created_by
  #   {Mdm::User#username Name of user} that created this report template.
  #
  #   @return [String]
  #   @todo https://www.pivotaltracker.com/story/show/52457961

  # @!attribute [rw] name
  #   Name of this report template.
  #
  #   @return [String]

  # @!attribute [rw] path
  #   Path to report template file on-disk.
  #
  #   @return [String]

  # @!attribute [rw] updated_at
  #   The last time this report template was updated.
  #
  #   @return [DateTime]

  #
  # Callbacks
  #

  before_destroy :delete_file

  private

  # Deletes file at {#path}, so that disk is cleaned when this report template is deleted from the database.
  #
  # @return [void]
  def delete_file
    c = Pro::Client.get rescue nil
    if c
      c.report_template_delete_file(self[:id])
    else
      ::File.unlink(self.path) rescue nil
    end
  end

  # Restore public for load hooks
  public

  ActiveSupport.run_load_hooks(:mdm_report_template, self)
end

