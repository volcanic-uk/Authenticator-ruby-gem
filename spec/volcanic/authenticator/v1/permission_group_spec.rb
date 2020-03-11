# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::PermissionGroup do
  let(:id) { nil }
  let(:name) { '' }
  let(:description) { '' }
  let(:subject_id) { 1 }
  let(:active) { true }
  let(:created_at) { 10.minutes.ago }
  let(:updated_at) { 10.minutes.ago }

  let(:params) do
    {
      id: id, name: name, description: description, subject_id: subject_id,
      active: active, created_at: created_at, updated_at: updated_at
    }
  end

  subject { described_class.new(params) }

  describe 'method' do
    describe '#initialise' do
      context 'with all required data' do
        it 'assigns correctly' do
          expect(subject.id).to eq(id)
          expect(subject.name).to eq(name)
          expect(subject.description).to eq(description)
          expect(subject.subject_id).to eq(subject_id)
          expect(subject.active).to eq(active)
          expect(subject.created_at).to eq(created_at)
          expect(subject.updated_at).to eq(updated_at)
        end
      end

      context 'with missing required data' do
        let(:params) do
          {
            description: description, subject_id: subject_id
          }
        end

        it 'raises an error' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end
end
