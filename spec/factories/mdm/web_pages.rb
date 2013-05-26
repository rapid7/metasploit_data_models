FactoryGirl.define do
  factory :mdm_web_page, :aliases => [:web_page], :class => Mdm::WebPage do
    code {FactoryGirl.generate :generic_html}
    #
    # Associations
    #
    association :web_site, :factory => :mdm_web_site
  end

  sequence :generic_html do |n|
    "<body><h1>LISTEN TO MASTODON, HUMAN #{n}!</h1></body>"
  end
end