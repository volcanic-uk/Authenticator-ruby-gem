# frozen_string_literal: true

RSpec.describe Vol::Auth::Z::PolicyItemRegistry do
  subject(:instance) { described_class.new }

  def create_policy(name)
    Class.new do
      @permission_name = name
      # rubocop:disable Style/TrivialAccessors
      def self.permission_name
        @permission_name
      end
      # rubocop:enable Style/TrivialAccessors
    end
  end

  let(:policy_item) { create_policy permission_name }
  let(:permission_name) { 'permission:1' }

  describe '#key?' do
    subject(:key?) { instance.key?(permission_name) }

    context 'when there is no policy registered' do
      it { is_expected.to be false }
    end

    context 'when a policy has been registered' do
      before { instance.register policy_item }
      it { is_expected.to be true }

      context 'and the policy requested is not registered' do
        subject(:key?) { instance.key?(:nothing) }
        it { is_expected.to be false }
      end
    end

    context 'when the policy has been registered for a different permission' do
      before { instance.register policy_item, 'other' }

      it('is not available under the normal name') { is_expected.to be false }
      it('is available under the provided name') do
        expect(instance.key?('other')).to be true
      end
    end

    context 'when a policy has been pre-registered' do
      before { instance.lazy_register(policy_item) }
      it { is_expected.to be true }
    end
  end

  describe '#policy_for' do
    subject(:policy_for) { instance.policy_for(permission_name) }

    context 'when there is a policy registered' do
      before { instance.register policy_item }
      it { is_expected.to be policy_item }
    end

    context 'when there are several policies registered' do
      before do
        instance.register policy_item
        instance.register create_policy('other')
      end

      it('returns the correct policy item') { is_expected.to be policy_item }
    end

    context 'when there is no policy registered for that permission' do
      subject { -> { instance.policy_for(:nothing) } }
      it { is_expected.to raise_error(Vol::Auth::Z::PolicyItemRegistry::PolicyItemNotFound) }
    end
  end
end
