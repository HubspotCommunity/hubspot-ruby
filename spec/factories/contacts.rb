
FactoryBot.define do
  factory :contact, class: Hubspot::Contact do
    to_create { |instance| instance.save }

    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.safe_email("#{Time.new.to_i.to_s[-5..-1]}#{(0..3).map { (65 + rand(26)).chr }.join}") }
  end
end