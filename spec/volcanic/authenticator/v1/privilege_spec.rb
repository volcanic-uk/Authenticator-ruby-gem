# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Privilege do
  let(:id) { nil }
  let(:scope) { '' }
  let(:permission_id) { 1 }
  let(:group_id) { 1 }
  let(:allow) { true }

  let(:params) do
    {
      id: id, scope: scope, permission_id: permission_id,
      group_id: group_id, allow: allow
    }
  end

  subject { described_class.new(params) }

  describe 'method' do
    describe '#initialise' do
      context 'with all required data' do
        it 'assigns correctly' do
          expect(subject.id).to eq(id)
          expect(subject.scope).to eq(scope)
          expect(subject.permission_id).to eq(permission_id)
          expect(subject.group_id).to eq(group_id)
          expect(subject.allow).to eq(allow)
        end
      end

      context 'with missing required data' do
        let(:params) do
          {
            group_id: group_id, allow: allow
          }
        end

        it 'raises an error' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end
end
