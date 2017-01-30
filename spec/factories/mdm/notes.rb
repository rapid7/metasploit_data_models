FactoryGirl.define do
  factory :mdm_note, :aliases => [:note], :class => Mdm::Note do
    #
    # Associations
    #
    association :workspace, :factory => :mdm_workspace
    association :host, :factory => :mdm_host
    association :service, :factory => :mdm_service

    ntype { generate :mdm_note_ntype }
  end

  sequence :mdm_note_ntype do |n|
    "note.ntype.instance#{n}"
  end
end