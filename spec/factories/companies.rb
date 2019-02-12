
FactoryBot.define do
  factory :company, class: Hubspot::Company do
    name Faker::Company.name

    skip_create
  end
end