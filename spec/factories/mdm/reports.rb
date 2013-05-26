FactoryGirl.define do
  factory :mdm_report, :aliases => [:report], :class => Mdm::Report do
    #
    # Associations
    #
    association :workspace, :factory => :mdm_workspace
    name{generate :report_name}
  end

  sequence :report_name do |n|
    "Some Report#{n}"
  end
end