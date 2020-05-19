# frozen_string_literal: true

RSpec::Matchers.define :be_a_urn do
  match do |actual|
    actual.is_a?(Volcanic::Authenticator::URN) &&
      { stack_id: :stack, dataset_id: :dataset, principal_id: :principal_id,
        identity_id: :identity_id }.all? do |key, meth|
        expected.key?(key) ? @actual.send(meth) == expected[key] : true
      end
  end

  chain(:with_stack) { |value| expected[:stack] = value }
  chain(:with_dataset) { |value| expected[:dataset] = value }
  chain(:with_principal_id) { |value| expected[:principal_id] = value }
  chain(:with_identity_id) { |value| expected[:identity_id] = value }

  def expected
    @expected ||= {}
  end
end

RSpec.describe Volcanic::Authenticator::URN do
  subject(:instance) { described_class.parse(urn) }

  let(:stack) { 'local' }
  let(:dataset_id) { '-1' }
  let(:principal_id) { 'volcanic' }
  let(:identity_id) { 'volcanic' }

  let(:urn) { "user://#{[stack, dataset_id, principal_id, identity_id].join('/')}" }

  describe 'parse' do
    context 'with an empty string' do
      let(:urn) { '' }
      it('raises an exception') { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'with a valid urn' do
      it { is_expected.to be_a_urn.with_stack(stack) }
      it { is_expected.to be_a_urn.with_dataset(dataset_id) }
      it { is_expected.to be_a_urn.with_principal_id(principal_id) }
      it { is_expected.to be_a_urn.with_identity_id(identity_id) }

      its(:to_s) { is_expected.to eq(urn) }
    end

    context 'with a missing identity' do
      let(:identity_id) { '' }

      it { is_expected.to be_a_urn.with_stack(stack) }
      it { is_expected.to be_a_urn.with_dataset(dataset_id) }
      it { is_expected.to be_a_urn.with_principal_id(principal_id) }
      it { is_expected.to be_a_urn.with_identity_id(nil) }

      its(:to_s) { is_expected.to eq("user://#{stack}/#{dataset_id}/#{principal_id}") }
    end

    context 'with a missing principal' do
      let(:principal_id) { '' }
      let(:identity_id) { '' }
      let(:urn) { "user://#{[stack, dataset_id, principal_id, identity_id].join('/')}" }

      it('raises an exception') { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#==' do
    subject { instance == other }

    context 'with the same object' do
      let(:other) { instance }
      it { is_expected.to be true }
    end

    context 'with an identical object' do
      let(:other) { described_class.parse(urn) }
      it { is_expected.to be true }
    end

    context 'with a urn that is different' do
      let(:other) { instance.dup }
      context 'only in the stack' do
        let(:other) { super().tap { |o| o.stack_id = 'different' } }
        it { is_expected.to be false }
      end

      context 'only in the dataset' do
        let(:other) { super().tap { |o| o.dataset_id = 'different' } }
        it { is_expected.to be false }
      end

      context 'only in the principal' do
        let(:other) { super().tap { |o| o.principal_id = 'different' } }
        it { is_expected.to be false }
      end

      context 'only in the identity' do
        let(:other) { super().tap { |o| o.identity_id = 'different' } }
        it { is_expected.to be false }
      end
    end

    context 'with a string value' do
      context 'that matches' do
        let(:other) { urn }
        it { is_expected.to be true }
      end

      context 'that is different' do
        let(:other) { 'user://not/the/same/urn' }
        it { is_expected.to be false }
      end

      context 'that is not a valid urn' do
        let(:other) { 'not even a urn' }
        it { is_expected.to be false }
      end
    end
  end
end
