FactoryGirl.define do
  factory :mdm_note, :aliases => [:note], :class => Mdm::Note do
    #
    # Associations
    #
    association :workspace, :factory => :mdm_workspace

  end
end