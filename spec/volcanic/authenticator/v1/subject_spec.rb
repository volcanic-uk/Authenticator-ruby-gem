# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Subject do
  let(:all_privileges) { JSON.parse(privileges_json)['response'] }
  let(:privileges_json) { File.read('./spec/privileges-for-ats.json') }
  let(:sub) { 'user://stack/dataset/principal/identity' }

  describe 'method' do
    before(:each) do
      allow(Volcanic::Authenticator::V1::Subject).to receive(:perform_get_and_parse) do
        all_privileges
      end
    end

    describe '#privileges_for' do
      subject { Volcanic::Authenticator::V1::Subject.privileges_for(sub, service) }

      context 'when privileges are returned' do
        let(:service) { 'ats' }

        it 'returns the correct response' do
          expect(subject).to be_a_kind_of(Array)
        end

        it 'contains the correct information' do
          expect(subject.first.permission.name).to eq('identity:create')
          expect(subject.first.scope).to eq('vrn:local:-1:identity/*')
          expect(subject.first.allow).to eq(true)
        end
      end

      context 'when a service does not exist' do
        let(:privileges_json) { File.read('./spec/privileges-for-none.json') }
        let(:service) { 'not-a-service' }

        it 'returns correctly' do
          expect(subject).to eq([])
        end
      end
    end

    describe '#permissions_for' do
      subject { Volcanic::Authenticator::V1::Subject.permissions_for(sub, service) }

      context 'when privileges are returned' do
        let(:service) { 'auth' }

        it 'returns an array' do
          expect(subject).to be_a_kind_of(Array)
        end

        it 'contains the correct information' do
          expect(subject.first).to be_a_kind_of(Volcanic::Authenticator::V1::Permission)
        end
      end
    end
  end
end
