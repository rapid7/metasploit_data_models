FactoryGirl.define do
  factory :mdm_report_template, :aliases => [:report_template], :class => Mdm::ReportTemplate do
    #
    # Associations
    #
    association :workspace, :factory => :mdm_workspace
  end
end