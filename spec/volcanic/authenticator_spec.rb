RSpec.describe Volcanic::Authenticator do
  before :all do
    @auth = Volcanic::Authenticator::V1::Method.new
  end

  describe '.create_identity' do
    before :all do
      @random_name = SecureRandom.hex 6
    end

    context 'Identity created' do
      before :all do
        @create_identity = @auth.identity_register(SecureRandom.hex(6))
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
        @auth.identity_register(name)
        error_req = @auth.identity_register(name)
        expect(JSON.parse(error_req)['reason']['message']).to eq("Duplicate entry #{name}")
      end

      it 'Name too short or too long' do
        error_req = @auth.identity_register(SecureRandom.hex(1))
        expect(JSON.parse(error_req)['reason']['data']['name'].first).to eq('Name must be between 5 and 32 characters.')
      end

      it 'Name too short or too long' do
        error_req = @auth.identity_register(SecureRandom.hex(33))
        expect(JSON.parse(error_req)['reason']['data']['name'].first).to eq('Name must be between 5 and 32 characters.')
      end

      it 'Validation Error' do
        error_req = @auth.identity_register(nil)
        expect(JSON.parse(error_req)['reason']['message']).to eq('ValidationError')
      end
    end
  end

  describe '.create_token' do
    before :all do
      create_identity = @auth.identity_register(SecureRandom.hex(6))
      @parsed = JSON.parse(create_identity)
      @create_token = @auth.identity_login(@parsed['identity_name'], @parsed['identity_secret'])
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
        res = @auth.identity_login('', SecureRandom.hex(12))
        expect(JSON.parse(res)['reason']['message']).to eq('invalid identity name or secret')
      end

      it 'missing secret' do
        res = @auth.identity_login(SecureRandom.hex(12), '')
        expect(JSON.parse(res)['reason']['message']).to eq('invalid identity name or secret')
      end
    end
  end

  describe '.deactivate_identity' do
    before :all do
      random_name = SecureRandom.hex 6
      create_identity = @auth.identity_register(random_name)
      @parsed = JSON.parse(create_identity)
      create_token = @auth.identity_login(@parsed['identity_name'], @parsed['identity_secret'])
      @token = JSON.parse(create_token)['token']
    end

    let(:deactivate_identity) { @auth.identity_deactivate(@parsed['identity_id'], @token) }

    it 'Success deactivate' do
      expect(deactivate_identity).to eq true
    end
  end

  describe '.validate_token' do
    before :all do
      create_identity = @auth.identity_register(SecureRandom.hex(6))
      identity_name = JSON.parse(create_identity)['identity_name']
      identity_secret = JSON.parse(create_identity)['identity_secret']
      create_token = @auth.identity_login(identity_name, identity_secret)
      @validate_token = @auth.identity_validate(JSON.parse(create_token)['token'])
    end

    context 'Valid token' do
      it 'return true value' do
        expect(@validate_token).to eq true
      end
    end

    context 'Invalid token' do
      it 'return false when nil token' do
        res = @auth.identity_validate(nil)
        expect(res).to eq false
      end

      it 'return false when when token invalid' do
        res = @auth.identity_validate(SecureRandom.hex(4))
        expect(res).to eq false
      end
    end
  end

  describe '.delete_token' do
    before :all do
      random_name = SecureRandom.hex 6
      create_identity = @auth.identity_register(random_name)
      @parsed = JSON.parse(create_identity)
      create_token = @auth.identity_login(@parsed['identity_name'], @parsed['identity_secret'])
      @token = JSON.parse(create_token)['token']
    end

    let(:delete_token) { @auth.identity_logout(@token) }

    it 'Success delete token' do
      expect(delete_token).to eq(true)
    end

    it 'Failed delete token' do
      expect(delete_token).to eq(false)
    end
  end

  # # describe '.clear' do
  # #   let(:clear) {Volcanic::Authenticator.clear}
  # #
  # #   it 'Success clear cache' do
  # #     expect(clear).to eq('OK')
  # #   end
  # #
  # # end
  #
  describe '.create_authority' do
    before :all do
      @random_name = SecureRandom.hex 6
    end

    context 'Authority created' do
      before :all do
        @authority = @auth.authority_create(@random_name, 1)
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
        res = @auth.authority_create(nil, 1)
        # expect(JSON.parse(res)['status']).to eq('error')
        expect(JSON.parse(res)['reason']['name'].first).to eq('The name is required')
      end

      it 'Missing creator_id' do
        res = @auth.authority_create(@random_name, nil)
        # expect(JSON.parse(res)['status']).to eq('error')
        expect(JSON.parse(res)['reason']['creator_id'].first).to eq('The creator is required')
      end

      it 'Duplicate name' do
        authority = @auth.authority_create(@random_name, 1)
        expect(JSON.parse(authority)['reason']['message']).to eq("Duplicate entry #{@random_name}")
      end
    end
  end

  describe '.create_group' do
    before :all do
      @name = SecureRandom.hex 6
      @creator = @auth.identity_register(SecureRandom.hex(6))
      @creator_id = JSON.parse(@creator)['identity_id'].to_i
      @authority = @auth.authority_create(SecureRandom.hex(6), @creator_id)
      @authority_id = JSON.parse(@creator)['authority_id'].to_i
      @group = @auth.group_create(@name, @creator_id, [@authority_id])
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
        error_group = @auth.group_create(@name, @creator_id, [@authority_id])
        expect(JSON.parse(error_group)['reason']['message']).to eq("Duplicate entry #{@name}")
      end
    end
  end

  # describe 'Generate public key' do
  #   it 'key created' do
  #     public_key = Volcanic::Authenticator.generate_public_key
  #     expect(JSON.parse(public_key)['key']).not_to be_empty
  #   end
  # end

  describe 'Get all caches' do
    it 'all caches' do
      res = @auth.list_caches
      p res
      expect(res).not_to be_nil
    end
  end
end
