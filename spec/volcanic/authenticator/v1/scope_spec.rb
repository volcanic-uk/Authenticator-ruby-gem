# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Scope do
  let(:scope) { 'vrn:local:-1:identity/1?user_id=123' }

  subject { described_class.parse(scope) }

  describe 'method' do
    describe '#parse' do
      it 'returns correctly' do
        expect(subject.class).to eq(described_class)
      end
    end

    describe '#initialize' do
      it 'assigns correctly' do
        expect(subject.to_s).to eq(scope)
        expect(subject.stack_id).to eq('local')
        expect(subject.dataset_id).to eq('-1')
        expect(subject.resource).to eq('identity')
        expect(subject.resource_id).to eq('1')
        expect(subject.qualifiers).to eq('user_id=123')
      end

      context 'missing elements have defaults' do
        let(:scope) { 'vrn:*:*:*' }

        it 'assigned correctly' do
          expect(subject.to_s).to eq('vrn:*:*:*')
          expect(subject.stack_id).to eq('*')
          expect(subject.dataset_id).to eq('*')
          expect(subject.resource).to eq('*')
          expect(subject.resource_id).to be_nil
          expect(subject.qualifiers).to be_nil
        end
      end
    end

    describe '.include?(other)' do
      subject { described_class.parse(scope).include?(other) }

      context 'with an exact match' do
        let(:scope) { 'vrn:local:-1:jobs/5' }

        context 'when other: vrn:local:-1:jobs/*' do
          let(:other) { 'vrn:local:-1:jobs/*' }
          it { is_expected.to eq(false) }
        end

        context 'when other: vrn:local:-1:jobs/5' do
          let(:other) { 'vrn:local:-1:jobs/5' }
          it { is_expected.to eq(true) }
        end
      end

      context 'with a wildcard scope' do
        let(:scope) { 'vrn:*:*:*' }

        context 'when stack, dataset and resource set' do
          let(:other) { 'vrn:local:-1:identity/*' }
          it { is_expected.to eq(true) }
        end

        context 'when wildcard stack, dataset and resource set' do
          let(:other) { 'vrn:*:*:identity/*' }
          it { is_expected.to eq(true) }
        end

        context 'when wildcard stack, dataset and resource, resource_id set' do
          let(:other) { 'vrn:*:*:jobs/5' }
          it { is_expected.to eq(true) }
        end
      end

      context 'with a stack set' do
        let(:scope) { 'vrn:local:*:*' }

        context 'when stack matches' do
          let(:other) { 'vrn:local:*:*' }
          it { is_expected.to eq(true) }
        end

        context 'when stack does not match' do
          let(:other) { 'vrn:eu-2:*:*' }
          it { is_expected.to eq(false) }
        end

        context 'when stack, dataset and resource are wildcards' do
          let(:other) { 'vrn:*:*:*' }
          it { is_expected.to eq(false) }
        end
      end

      context 'with a dataset set' do
        let(:scope) { 'vrn:*:-1:*' }

        context 'when dataset matches' do
          let(:other) { 'vrn:*:-1:*' }
          it { is_expected.to eq(true) }
        end

        context 'when dataset does not match' do
          let(:other) { 'vrn:*:1:*' }
          it { is_expected.to eq(false) }
        end

        context 'when stack, dataset and resource are wildcards' do
          let(:other) { 'vrn:*:*:*' }
          it { is_expected.to eq(false) }
        end
      end

      context 'resource' do
        let(:scope) { 'vrn:*:*:jobs/*' }

        context 'when the resource is a wildcard' do
          let(:other) { 'vrn:*:*:jobs/*' }
          it { is_expected.to eq(true) }
        end

        context 'when resource does not match' do
          let(:other) { 'vrn:*:*:job/*' }
          it { is_expected.to eq(false) }
        end

        context 'when stack, dataset and resource are wildcards' do
          let(:other) { 'vrn:*:*:*' }
          it { is_expected.to eq(false) }
        end
      end

      context 'resource_id' do
        let(:scope) { 'vrn:*:*:jobs/5' }

        context 'when resource_id matches' do
          let(:other) { 'vrn:*:*:jobs/5' }
          it { is_expected.to eq(true) }
        end

        context 'when resource_id does not match' do
          let(:other) { 'vrn:*:*:jobs/6' }
          it { is_expected.to eq(false) }
        end

        context 'when when resource does not match but resource_id does' do
          let(:other) { 'vrn:*:*:job/6' }
          it { is_expected.to eq(false) }
        end

        context 'when stack, dataset and resource are wildcards' do
          let(:other) { 'vrn:*:*:*' }
          it { is_expected.to eq(false) }
        end
      end
    end

    describe '.score' do
      subject { described_class.parse(scope).specificity_score }

      context 'for stack_id' do
        context 'with a wildcard' do
          let(:scope) { 'vrn:*:*:*/*' }

          it { is_expected.to eq(0) }
        end
        context 'with a value' do
          let(:scope) { 'vrn:local:*:*/*' }

          it { is_expected.to eq(1) }
        end
      end

      context 'for dataset_id' do
        context 'with a wildcard' do
          let(:scope) { 'vrn:*:*:*/*' }

          it { is_expected.to eq(0) }
        end
        context 'with a value' do
          let(:scope) { 'vrn:*:-1:*/*' }

          it { is_expected.to eq(2) }
        end
      end

      context 'for resource' do
        context 'with a wildcard' do
          let(:scope) { 'vrn:*:*:*/*' }

          it { is_expected.to eq(0) }
        end
        context 'with a value' do
          let(:scope) { 'vrn:*:*:jobs/*' }

          it { is_expected.to eq(3) }
        end
      end

      context 'for resource_id' do
        context 'with a wildcard' do
          let(:scope) { 'vrn:*:*:jobs/*' }

          it { is_expected.to eq(3) }
        end
        context 'with a value' do
          let(:scope) { 'vrn:*:-1:jobs/14' }

          it { is_expected.to eq(9) }
        end
      end

      context 'for resource_id with qualifiers' do
        context 'with a value' do
          let(:scope) { 'vrn:*:-1:jobs/14?this=that' }

          it { is_expected.to eq(14.0) }
        end
      end
    end
  end
end
