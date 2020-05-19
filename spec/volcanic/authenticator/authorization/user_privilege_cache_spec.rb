# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::Authorization::UserPrivilegeCache do
  describe '#privileges_for' do
    let(:urn) { Vol::Auth::URN.new(stack_id: 'local', dataset_id: dataset, principal_id: principal, identity_id: identity) }
    let(:other_urn) { Vol::Auth::URN.new(stack_id: 'local', dataset_id: dataset, principal_id: principal, identity_id: 'other') }
    let(:service) { 'my-service' }
    let(:permission_name) { 'my:permission' }
    let(:my_permission) { Vol::Auth::V1::Permission.new(name: permission_name, id: 1) }
    let(:other_permission) { Vol::Auth::V1::Permission.new(name: 'other:permission', id: 2) }
    let(:dataset) { 'ds-25' }
    let(:principal) { 'principal-dave' }
    let(:identity) { 'identity-dave' }
    let(:all_found_privileges) { [].concat(privileges_for_my_permission).concat(privileges_for_other_permission) }
    let(:other_found_privileges) { privileges_for_other_user }

    let(:privileges_for_my_permission) do
      (1..10).map do |i|
        Vol::Auth::V1::Privilege.new(scope: "vrn:local:*:foo/#{i}", permission_id: my_permission.id, allow: true)
      end
    end
    let(:privileges_for_other_permission) do
      (1..10).map do |i|
        Vol::Auth::V1::Privilege.new(scope: "vrn:local:*:foo/#{i}", permission_id: other_permission.id, allow: true)
      end
    end
    let(:privileges_for_other_user) do
      (1..10).map do |i|
        Vol::Auth::V1::Privilege.new(scope: "vrn:local:*:foo/#{i}", permission_id: other_permission.id, allow: true)
      end
    end

    before do
      allow(Vol::Auth::V1::Subject).to receive(:privileges_for).with(urn.to_s, service).and_return(all_found_privileges)
      allow(Vol::Auth::V1::Subject).to receive(:privileges_for).with(other_urn.to_s, service).and_return(other_found_privileges)
      allow(Vol::Auth::V1::Permission).to receive(:find_by_id).with(my_permission.id).and_return(my_permission)
      allow(Vol::Auth::V1::Permission).to receive(:find_by_id).with(other_permission.id).and_return(other_permission)
    end

    subject { described_class.privileges_for(urn, service, permission_name) }

    it('contains the privileges for that permission only') { is_expected.to contain_exactly(*privileges_for_my_permission) }

    context do
      subject { described_class.privileges_for(other_urn, service, other_permission.name) }
      it('contains the privileges for that user only') { is_expected.to contain_exactly(*privileges_for_other_user) }
    end

    context do
      before do
        expect(Vol::Auth::V1::Subject).to receive(:privileges_for)
          .with(urn.to_s, service) \
          .once \
          .and_return(all_found_privileges)
        described_class.privileges_for(urn, service, permission_name)
      end

      it 'caches the privileges' do
        described_class.privileges_for(urn, service, permission_name)
      end
    end
  end
end
