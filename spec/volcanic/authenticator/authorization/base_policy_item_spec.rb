# frozen_string_literal: true

RSpec.describe Vol::Auth::Z::BasePolicyItem do
  let!(:child_policy) do
    Class.new(Vol::Auth::Z::BasePolicyItem) do
      self.permission_name = 'my_permission'
      self.service_name = 'my_service'
    end
  end

  let(:target) { double(:target, vrn: 'vrn:local:ds:myresource/25') }
  let(:current_user) { double(:current_user, urn: 'user://local/dataset/test/ident') }
  let(:all_privileges) { [] }
  let(:service_name) { 'my_service' }
  let(:permission_name) { 'my_permission' }

  # because we expect that the class will be extended, and the child class will override a
  # number of methods, test against a subclass
  subject(:instance) { child_policy.new(current_user, target) }

  before do
    allow(Vol::Auth::Z::UserPrivilegeCache).to receive(:privileges_for)
      .with(current_user.urn, service_name, permission_name)
      .and_return(all_privileges)
  end

  describe 'when inherited' do
    it 'registers the child with the policy registry' do
      expect(Vol::Auth::Z::PolicyItemRegistry.policy_for('my_permission')).to eq(child_policy)
    end
  end

  describe '#privileges' do
    subject { instance.privileges }
    it('is all of the privileges that user has for that permission') { is_expected.to eq(all_privileges) }
  end

  describe '#qualified_privileges' do
    let(:valid_privileges) do
      [Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*', allow: true),
       Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*?min=1&max=5', allow: true),
       Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/25', allow: false)]
    end
    let(:invalid_privileges) do
      [Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:other/*', allow: true),
       Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/otherid', allow: false),
       Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*?foo=bar', allow: true)]
    end
    let(:all_privileges) { valid_privileges.dup.concat(invalid_privileges) }

    subject { instance.qualified_privileges }

    it 'provides only the subset of privileges where the target vrn is in scope' do
      expect(instance).to receive(:qualifiers_valid?)
        .with('foo' => 'bar')
        .and_return(false)
      expect(instance).to receive(:qualifiers_valid?)
        .with('min' => '1', 'max' => '5')
        .and_return(true)

      expect(subject).to contain_exactly(*valid_privileges)
    end
  end

  describe '#authorized?' do
    subject(:authorized) { instance.authorized? }

    before do
      # normally we wouldn't stub the internal methods.... but given the potential complexity
      # testing that method separately and stubbing is simpler
      allow(instance).to receive(:qualified_privileges).and_return(qualified_privileges)
    end

    context 'when there are no privileges' do
      let(:qualified_privileges) { [] }
      it { is_expected.to be false }
    end

    context 'when there is only one privilege' do
      let(:allowed) { double(:allowed) }
      let(:qualified_privileges) { [Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*', allow: allowed)] }
      it('defers to the privilege') { is_expected.to be allowed }
    end

    context 'when there are several privileges' do
      context 'and all are allow' do
        let(:qualified_privileges) do
          [Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*?min=1&max=5', allow: true),
           Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/25', allow: true)]
        end

        it { is_expected.to be true }
      end

      context 'and all are deny' do
        let(:qualified_privileges) do
          [Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*?min=1&max=5', allow: false),
           Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/25', allow: false)]
        end

        it { is_expected.to be false }
      end

      context 'and at least one is deny and at least one is allow' do
        let(:qualified_privileges) do
          [Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/*?min=1&max=5', allow: true),
           Vol::Auth::V1::Privilege.new(scope: 'vrn:*:*:myresource/25', allow: false)]
        end

        it('expects the inheriting class to handle it') { is_expected.to be nil }
      end
    end
  end
end
