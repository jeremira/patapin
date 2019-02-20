FactoryBot.define do
  factory :event do

    trait :opening do
      kind { "opening" }
    end
    trait :appointment do
      kind { "appointment" }
    end
  end
end
