
FactoryBot.define do
  factory :company, class: Hubspot::Company do
    to_create { |instance| instance.save }

    name Faker::Company.name
    domain Faker::Internet.domain_name
  end
end