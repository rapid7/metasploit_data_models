FactoryGirl.define do
  factory :mdm_web_form, :aliases => [:web_form], :class => Mdm::WebForm do
    #
    # Associations
    #
    association :web_site, :factory => :mdm_web_site
  end
end
