
FactoryBot.define do
  factory :company, class: HubspotLegacy::Company do
    to_create { |instance| instance.save }

    add_attribute(:name) { Faker::Company.name }
    add_attribute(:domain) { Faker::Internet.domain_name }
  end
end
