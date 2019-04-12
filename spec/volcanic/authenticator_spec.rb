RSpec.describe Volcanic::Authenticator do

  describe '.create_identity' do
    let(:create_identity) {Volcanic::Authenticator.create_identity('new', nil)}
    it 'identity_name created' do
      expect(JSON.parse(create_identity)['identity_name']).not_to be_empty
    end

    it 'identity_secret created' do
      expect(JSON.parse(create_identity)['identity_secret']).not_to be_empty
    end
  end

  describe '.create_authority' do
    let(:create_authority) {Volcanic::Authenticator.create_authority('new')}
    it 'Authority created' do
      expect(JSON.parse(create_authority)['status']).to eq('Authority has been added')
    end
  end

  describe '.create_group' do
    let(:create_group) {Volcanic::Authenticator.create_group('new', [])}
    it 'Group created' do
      expect(JSON.parse(create_group)['status']).to eq('group has been created')
    end
  end

  describe '.create_token' do
    let(:create_token) {Volcanic::Authenticator.create_token('identiy_name', 'identity_secret')}
    it 'Token created' do
      expect(JSON.parse(create_token)['token']).not_to be_empty
    end
  end

  describe '.validate_token' do
    let(:validate_token) {Volcanic::Authenticator.validate_token('identiy_name')}

    it 'valid token' do
      expect(validate_token).to eq(true)
    end

    it 'invalid token' do
      expect(validate_token).to eq(false)
    end
  end

end
