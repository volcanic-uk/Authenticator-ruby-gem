RSpec.describe Volcanic::Authenticator do
  describe '.create_identity' do
    before :all do
      @random_name = SecureRandom.hex 6
    end

    context 'Identity created' do
      before :all do
        @create_identity = Volcanic::Authenticator.generate_identity(@random_name)
      end

      it 'return "success" status' do
        expect(JSON.parse(@create_identity)['status']).to eq('success')
      end

      it 'identity_name created' do
        expect(JSON.parse(@create_identity)['identity_name']).not_to be_empty
      end

      it 'identity_secret created' do
        expect(JSON.parse(@create_identity)['identity_secret']).not_to be_empty
      end
    end

    context 'Failed create identity' do
      it 'Duplicate name' do
        name = SecureRandom.hex(5)
        Volcanic::Authenticator.generate_identity(name)
        error_req = Volcanic::Authenticator.generate_identity(name)
        expect(JSON.parse(error_req)['reason']['message']).to eq("Duplicate entry #{name}")
      end

      it 'Name too short or too long' do
        error_req = Volcanic::Authenticator.generate_identity(SecureRandom.hex(1))
        expect(JSON.parse(error_req)['reason']['data']['name'].first).to eq('Name must be between 5 and 32 characters.')
      end

      it 'Name too short or too long' do
        error_req = Volcanic::Authenticator.generate_identity(SecureRandom.hex(33))
        expect(JSON.parse(error_req)['reason']['data']['name'].first).to eq('Name must be between 5 and 32 characters.')
      end

      it 'Validation Error' do
        error_req = Volcanic::Authenticator.generate_identity(nil)
        expect(JSON.parse(error_req)['reason']['message']).to eq('ValidationError')
      end
    end
  end

  describe '.create_token' do
    before :all do
      create_identity = Volcanic::Authenticator.generate_identity(SecureRandom.hex(6))
      @parsed = JSON.parse(create_identity)
      @create_token = Volcanic::Authenticator.generate_token(@parsed['identity_name'], @parsed['identity_secret'])
    end

    # let(:create_token) {Volcanic::Authenticator.create_token(@parsed['identity_name'], @parsed['identity_secret'])}

    context 'Token created' do
      it 'return "success" status' do
        expect(JSON.parse(@create_token)['status']).to eq('success')
      end

      it 'return token' do
        expect(JSON.parse(@create_token)['token']).not_to be_empty
      end
    end

    context 'return "invalid identity name or secret"' do
      it 'missing identity' do
        res = Volcanic::Authenticator.generate_token('', '9993a115f14856b8d2e28546f0e1aa006b9ba469')
        expect(JSON.parse(res)['reason']['message']).to eq('invalid identity name or secret')
      end

      it 'missing secret' do
        res = Volcanic::Authenticator.generate_token('new_identity_10', '')
        expect(JSON.parse(res)['reason']['message']).to eq('invalid identity name or secret')
      end
    end
  end

  describe '.deactivate_identity' do
    before :all do
      random_name = SecureRandom.hex 6
      create_identity = Volcanic::Authenticator.generate_identity(random_name)
      @parsed = JSON.parse(create_identity)
      create_token = Volcanic::Authenticator.generate_token(@parsed['identity_name'], @parsed['identity_secret'])
      @token = JSON.parse(create_token)['token']
    end

    let(:deactivate_identity) { Volcanic::Authenticator.deactivate_identity(@parsed['identity_id'], @token) }

    it 'Success deactivate' do
      expect(deactivate_identity).to eq true
    end
  end

  describe '.validate_token' do
    before :all do
      create_identity = Volcanic::Authenticator.generate_identity(SecureRandom.hex(6))
      identity_name = JSON.parse(create_identity)['identity_name']
      identity_secret = JSON.parse(create_identity)['identity_secret']
      create_token = Volcanic::Authenticator.generate_token(identity_name, identity_secret)
      @validate_token = Volcanic::Authenticator.validate_token(JSON.parse(create_token)['token'])
    end

    context 'Valid token' do
      it 'return true value' do
        expect(@validate_token).to eq true
      end
    end

    context 'Invalid token' do
      it 'return false when nil token' do
        res = Volcanic::Authenticator.validate_token(nil)
        expect(res).to eq false
      end

      it 'return false when when token invalid' do
        res = Volcanic::Authenticator.validate_token(SecureRandom.hex(4))
        expect(res).to eq false
      end
    end
  end

  describe '.delete_token' do
    before :all do
      random_name = SecureRandom.hex 6
      create_identity = Volcanic::Authenticator.generate_identity(random_name)
      @parsed = JSON.parse(create_identity)
      create_token = Volcanic::Authenticator.generate_token(@parsed['identity_name'], @parsed['identity_secret'])
      @token = JSON.parse(create_token)['token']
    end

    let(:delete_token) { Volcanic::Authenticator.delete_token(@token) }

    it 'Success delete token' do
      expect(delete_token).to eq(true)
    end

    it 'Failed delete token' do
      expect(delete_token).to eq(false)
    end
  end

  # describe '.clear' do
  #   let(:clear) {Volcanic::Authenticator.clear}
  #
  #   it 'Success clear cache' do
  #     expect(clear).to eq('OK')
  #   end
  #
  # end

  describe '.create_authority' do
    before :all do
      @random_name = SecureRandom.hex 6
    end

    context 'Authority created' do
      before :all do
        @authority = Volcanic::Authenticator.create_authority(@random_name, 1)
      end

      it 'return "success" status' do
        expect(JSON.parse(@authority)['status']).to eq('success')
      end

      it 'return authority name' do
        expect(JSON.parse(@authority)['authority_name']).to eq(@random_name)
      end

      it 'return authority id' do
        expect(JSON.parse(@authority)['authority_id']).not_to be_nil
      end
    end

    context 'Validation error' do
      it 'Missing name' do
        res = Volcanic::Authenticator.create_authority(nil, 1)
        # expect(JSON.parse(res)['status']).to eq('error')
        expect(JSON.parse(res)['reason']['name'].first).to eq('The name is required')
      end

      it 'Missing creator_id' do
        res = Volcanic::Authenticator.create_authority(@random_name, nil)
        # expect(JSON.parse(res)['status']).to eq('error')
        expect(JSON.parse(res)['reason']['creator_id'].first).to eq('The creator is required')
      end

      it 'Duplicate name' do
        authority = Volcanic::Authenticator.create_authority(@random_name, 1)
        expect(JSON.parse(authority)['reason']['message']).to eq("Duplicate entry #{@random_name}")
      end
    end
  end

  describe '.create_group' do
    before :all do
      @name = SecureRandom.hex 6
      @creator = Volcanic::Authenticator.generate_identity(SecureRandom.hex(6))
      @creator_id = JSON.parse(@creator)['identity_id'].to_i
      @authority = Volcanic::Authenticator.create_authority(SecureRandom.hex(6), @creator_id)
      @authority_id = JSON.parse(@creator)['authority_id'].to_i
      @group = Volcanic::Authenticator.create_group(@name, @creator_id, [@authority_id])
    end

    context 'Group created' do
      it 'return "success" status' do
        expect(JSON.parse(@group)['status']).to eq('success')
      end

      it 'return group name' do
        expect(JSON.parse(@group)['group_name']).to eq(@name)
      end

      it 'return group id' do
        expect(JSON.parse(@group)['group_id']).not_to be_nil
      end
    end

    context 'Error on create group' do
      it 'Duplicate name' do
        error_group = Volcanic::Authenticator.create_group(@name, @creator_id, [@authority_id])
        expect(JSON.parse(error_group)['reason']['message']).to eq("Duplicate entry #{@name}")
      end
    end
  end

  describe 'Generate public key' do
    it 'key created' do
      public_key = Volcanic::Authenticator.generate_public_key
      expect(JSON.parse(public_key)['key']).not_to be_empty
    end
  end
end
