# frozen_string_literal: true

RSpec::Matchers.define :be_a_scope do
  match do |actual|
    actual.is_a?(Volcanic::Authenticator::V1::Scope) &&
      { stack: :stack_id, dataset: :dataset_id, resource: :resource,
        resource_id: :resource_id, qualifiers: :qualifiers }.all? do |key, meth|
        expected.key?(key) ? @actual.send(meth) == expected[key] : true
      end
  end

  chain(:with_stack) { |value| expected[:stack] = value }
  chain(:with_dataset) { |value| expected[:dataset] = value }
  chain(:with_resource) { |value| expected[:resource] = value }
  chain(:with_resource_id) { |value| expected[:resource_id] = value }
  chain(:with_qualifiers) { |value| expected[:qualifiers] = value }

  def expected
    @expected ||= {}
  end
end

RSpec.describe Volcanic::Authenticator::V1::Scope do
  let(:scope) { 'vrn:local:-1:identity/1?user_id=123' }

  subject { described_class.parse(scope) }

  describe 'method' do
    describe '#parse' do
      context 'with a Scope object' do
        let(:scope) { described_class.new }
        it('returns the same object') { is_expected.to be(scope) }
      end

      context 'with an empty string' do
        let(:scope) { '' }
        it('raises an exception') { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'with a valid scope string' do
        let(:scope) { 'vrn:local:-1:identity/1?user_id=123' }

        it { is_expected.to be_a_scope.with_stack('local') }
        it { is_expected.to be_a_scope.with_dataset('-1') }
        it { is_expected.to be_a_scope.with_resource('identity') }
        it { is_expected.to be_a_scope.with_resource_id('1') }
        it { is_expected.to be_a_scope.with_qualifiers('user_id=123') }

        context 'where there is no qualifier' do
          let(:scope) { 'vrn:local:-1:identity/1' }

          it 'parses correctly and sets qualifiers as nil' do
            is_expected.to be_a_scope
              .with_stack('local')
              .with_dataset('-1')
              .with_resource('identity')
              .with_resource_id('1')
              .with_qualifiers(nil)
          end
        end

        context 'where there is no resource id' do
          let(:scope) { 'vrn:local:-1:identity?user_id=123' }

          it 'parses correctly and sets the resource ID as nil' do
            is_expected.to be_a_scope
              .with_stack('local')
              .with_dataset('-1')
              .with_resource('identity')
              .with_resource_id(nil)
              .with_qualifiers('user_id=123')
          end
        end

        context 'where the resource id is a wildcard' do
          let(:scope) { 'vrn:local:-1:identity/*?user_id=123' }

          it 'parses correctly and sets the resource ID as *' do
            is_expected.to be_a_scope
              .with_stack('local')
              .with_dataset('-1')
              .with_resource('identity')
              .with_resource_id('*')
              .with_qualifiers('user_id=123')
          end
        end
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

    describe '.vrn_without_qualifiers' do
      subject { described_class.parse(scope).vrn_without_qualifiers }

      context 'with qualifiers' do
        let(:scope) { 'vrn:local:-1:identity/2?foo=bar' }

        it 'doesn\'t return qualifiers' do
          expect(subject).to eq('vrn:local:-1:identity/2')
        end
      end

      context 'without qualifiers' do
        let(:scope) { 'vrn:local:-1:identity/2' }

        it 'doesn\'t return qualifiers' do
          expect(subject).to eq(scope)
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

    describe '#==' do
      let(:original) { described_class.parse(scope) }
      let(:other) { described_class.parse(other_scope) }
      let(:other_scope) { scope }

      subject { original == other }

      context 'when the two are the same object' do
        let(:other) { original }

        it { is_expected.to be true }
      end

      context 'when the two have the same vrn' do
        it { is_expected.to be true }
      end

      context 'when the two have different vrns' do
        let(:other_scope) { 'vrn:not:like:others/atall' }
        it { is_expected.to be false }
      end

      context 'when other cannot be pared to a Scope' do
        let(:other) { nil }
        it { is_expected.to be false }
      end

      context 'when comparing with a vrn' do
        context 'and the vrn is the same as the parsed value' do
          let(:other) { other_scope }
          it { is_expected.to be true }
        end

        context 'and the vrn is different to the parsed value' do
          let(:other) { 'vrn:not:like:others/atall' }
          it { is_expected.to be false }
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
