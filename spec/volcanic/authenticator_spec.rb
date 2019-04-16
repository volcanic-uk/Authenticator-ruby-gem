RSpec.describe Volcanic::Authenticator do

  describe '.create_identity' do

    before :all do
      @random_name = SecureRandom.hex 6
    end

    context 'Identity created' do

      before :all do
        @create_identity = Volcanic::Authenticator.create_identity(@random_name)
      end

      it 'return "success" status' do
        expect(JSON.parse(@create_identity)['status']).to eq('success')
      end

      it 'identity_name created' do
        expect(JSON.parse(@create_identity)['identity_name']).not_to be_empty
      end

      it 'identity_name created' do
        expect(JSON.parse(@create_identity)['identity_secret']).not_to be_empty
      end
    end

    context 'Failed create identity' do
      before :all do
        @create_identity = Volcanic::Authenticator.create_identity(@random_name)
      end

      it 'return "error" status' do
        expect(JSON.parse(@create_identity)['status']).to eq('error')
      end

      it 'Duplicate name error' do
      end

      it 'Validation Error' do
        error_req = Volcanic::Authenticator.create_identity(nil)
        expect(JSON.parse(error_req)['error']['reason']['message']).to eq("ValidationError")
      end
    end

  end


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

    context 'Duplicate name' do
      before :all do
        @authority = Volcanic::Authenticator.create_authority(@random_name, 1)
      end

      it 'return "error" status' do
        expect(JSON.parse(@authority)['status']).to eq('error')
      end

      it 'return "Duplicate" message' do
        expect(JSON.parse(@authority)['error']['reason']['message']).to eq("Duplicate entry #{@random_name}")
      end

    end

    context "Validation error" do
      it 'error missing name' do
        res = Volcanic::Authenticator.create_authority(nil, 1)
        expect(JSON.parse(res)['status']).to eq('error')
        expect(JSON.parse(res)['error']['reason']['name'].first).to eq('The name is required')
      end

      it 'error missing creator_id' do
        res = Volcanic::Authenticator.create_authority(@random_name, nil)
        expect(JSON.parse(res)['status']).to eq('error')
        expect(JSON.parse(res)['error']['reason']['creator_id'].first).to eq('The creator is required')
      end
    end

  end

  # describe '.create_group' do
  #   let(:create_group) {Volcanic::Authenticator.create_group('new', [])}
  #   it 'Group created' do
  #     expect(JSON.parse(create_group)['status']).to eq('group has been created')
  #   end
  # end
  #
  # describe '.create_token' do
  #   let(:create_token) {Volcanic::Authenticator.create_token('identiy_name', 'identity_secret')}
  #   it 'Token created' do
  #     expect(JSON.parse(create_token)['token']).not_to be_empty
  #   end
  # end
  #
  # describe '.validate_token' do
  #   let(:validate_token) {Volcanic::Authenticator.validate_token('identiy_name')}
  #
  #   it 'valid token' do
  #     expect(validate_token).to eq(true)
  #   end
  #
  #   it 'invalid token' do
  #     expect(validate_token).to eq(false)
  #   end
  # end
  #
  # describe '.delete_token' do
  #   let(:delete_token) {Volcanic::Authenticator.delete_token('identiy_name')}
  #
  #   it 'Success delete token' do
  #     expect(delete_token).to eq(true)
  #   end
  #
  #   it 'Failed delete token' do
  #     expect(delete_token).to eq(false)
  #   end
  # end
  #
  # describe '.clear' do
  #   let(:clear) {Volcanic::Authenticator.clear}
  #
  #   it 'Success clear cache' do
  #     expect(clear).to eq('OK')
  #   end
  #
  # end
  #
  # describe '.list' do
  #   let(:list) {Volcanic::Authenticator.list}
  #
  #   it 'List all cache token' do
  #     expect(list).not_to be_nil
  #   end
  #
  # end
  #

  # describe '.decode' do
  #   let(:decode) {Volcanic::Authenticator.decode_token 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.4Adcj3UFYzPUVaVF43FmMab6RlaQD8A9V8wFzzht-KQ'}
  #   it 'Success decode' do
  #     p decode
  #     expect(decode).not_to be_nil
  #   end
  # end

end
