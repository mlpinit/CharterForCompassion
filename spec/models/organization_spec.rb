require 'spec_helper'

describe Organization, type: :model do
  context 'when all organization attributes exist' do
    let(:organization) { create(:organization) }

    it 'creates a valid organization' do
      expect(organization.valid?).to be(true)
    end

    it 'geocodes the address' do
      expect(organization.latitude).not_to be(nil)
      expect(organization.longitude).not_to be(nil)
    end

    it 'does not geocode if the address has not changed' do
      expect(organization).not_to receive(:geocode)
      organization.name = "Ruby for Good"
      organization.save
    end
  end

  describe '#full_street_address' do
    let(:organization) do
      create(
        :organization,
        street: '123 Main St.',
        city: 'Spring',
        state: 'VA',
        zipcode: '20009'
      )
    end

    it 'returns a string with the street, city, state, and zip code combined' do
      expect(organization.full_street_address).to eq('123 Main St. Spring, VA 20009')
    end
  end

  describe '#full_street_address_changed?' do
    let(:organization) { create(:organization) }

    it 'returns true if any of street, city, state, zipcode changes' do
      expect(organization.full_street_address_changed?).to be(false)

      ["street=", "city=", "state=", "zipcode="].each do |attribute|
        organization = create(:organization)
        organization.send(attribute, "SOMETHING ELSE")
        expect(organization.full_street_address_changed?).to be(true)
      end
    end
  end

  describe 'scope' do
    let(:user_one) do
      create(
        :user,
        street: '350 Fifth Avenue',
        city: 'New York',
        state: 'NY',
        zipcode: '10118'
      )
    end

    let(:org_one) do
      create(
        :organization,
        name: 'Metropolitan Museum of Art',
        street: '1000 5th Ave',
        city: 'New York',
        state: 'NY',
        zipcode: '10028'
      )
    end

    let(:org_two) do
      create(
        :organization,
        name: 'Faneuil Hall Marketplace',
        street: '4 South Market Building',
        city: 'Boston',
        state: 'MA',
        zipcode: '02109'
      )
    end

    # TODO: Fix these to work with organizations once skills and interests are added
    # describe '.search_by_interest' do
    #   let(:interest) { create(:interest) }

    #   before { user_one.interests << interest }

    #   it 'returns users associated with that interest' do
    #     expect(described_class.search_by_interest(interest.interest))
    #       .to include(user_one)
    #   end

    #   it 'does NOT return users that are NOT associated with that interest' do
    #     expect(described_class.search_by_interest(interest.interest))
    #       .not_to include(user_two)
    #   end

    #   it 'returns all users if no interest is given' do
    #     expect(described_class.search_by_interest(''))
    #       .to include(user_one, user_two)
    #   end
    # end

    # describe '.search_by_skill' do
    #   let(:skill) { create(:skill) }

    #   before { user_one.skills << skill }

    #   it 'returns users associated with that skill' do
    #     expect(described_class.search_by_skill(skill.skill))
    #       .to include(user_one)
    #   end

    #   it 'does NOT return users that are NOT associated with that skill' do
    #     expect(described_class.search_by_skill(skill.skill))
    #       .not_to include(user_two)
    #   end

    #   it 'returns all users if no skill is given' do
    #     expect(described_class.search_by_skill(''))
    #       .to include(user_one, user_two)
    #   end
    # end

    describe '.search_by_distance' do 
      it 'returns organization within a certain distance' do
        expect(described_class.search_by_distance(user_one, rand(200..500)))
          .to include(org_one, org_two)
      end

      it 'does NOT return organizations outside of the range' do
        expect(described_class.search_by_distance(user_one, rand(20..50)))
          .to include(org_one)
        expect(described_class.search_by_distance(user_one, rand(20..50)))
          .not_to include(org_two)
      end
    end
  end
end
