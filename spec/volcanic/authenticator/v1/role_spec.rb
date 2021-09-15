# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Role, vcr: { match_requests_on: %i[method uri] } do
  before do
    Configuration.set
    allow(Volcanic::Authenticator::V1::AppToken).to receive(:fetch_and_request).and_return('')
  end

  let(:role) { Volcanic::Authenticator::V1::Role }
  let(:role_error) { Volcanic::Authenticator::V1::RoleError }
  let(:mock_name) { 'mock_name' }
  let(:mock_privilege_ids) { [1, 2] }

  describe '#create' do
    subject { role.create(mock_name, privilege_ids: mock_privilege_ids) }

    context 'when invalid' do
      context 'when name is missing' do
        it { expect { role.create('') }.to raise_error role_error }
        it { expect { role.create(nil) }.to raise_error role_error }
      end

      context 'when privilege_ids not an array' do
        it { expect { role.create(mock_name, privilege_ids: 1) }.to raise_error role_error }
      end

      context 'when privilege_ids not exist' do
        it { expect { role.create(mock_name, privilege_ids: [123_456_789]) }.to raise_error role_error }
      end

      context 'when parent_id not exist' do
        it { expect { role.create(mock_name, parent_id: 123_456_789) }.to raise_error role_error }
      end

      context 'when duplicate name' do
        before { role.create(mock_name) }
        it { expect { role.create(mock_name) }.to raise_error role_error }
      end
    end

    context 'when valid' do
      its(:name) { should eq mock_name }
    end
  end

  describe '#find' do
    context 'when find by id' do
      subject { role.find_by_id(1) }
      its(:name) { should eq mock_name }
    end

    context 'when find by name' do
      subject { role.find(name: mock_name).first }
      its(:name) { should eq mock_name }
    end

    context 'when find with specific page' do
      subject { role.find(page: 2) }
      its(:page) { should eq 2 }
    end

    context 'when find with specific page size' do
      subject { role.find(page_size: 2) }
      its(:page_size) { should eq 2 }
    end

    context 'when find with query' do
      subject(:roles) { role.find(query: mock_name) }
      it { expect(roles[0].name).to eq mock_name }
    end

    context 'when find with pagination' do
      subject(:roles) { role.find }
      it { expect(roles.page).to eq 1 }
      it { expect(roles.page_size).to eq 10 }
      it { expect(roles.row_count).to eq 20 }
      it { expect(roles.page_count).to eq 2 }
    end
  end

  describe '#save' do
    subject(:instance) { role.new(id: 1) }

    context 'when invalid' do
      context 'when name is nil' do
        before { instance.name = nil }
        it { expect { instance.save }.to raise_error role_error }
      end

      context 'when name is empty' do
        before { instance.name = '' }
        it { expect { instance.save }.to raise_error role_error }
      end

      context 'when name is taken (duplicates)' do
        before { instance.name = mock_name }
        it { expect { instance.save }.to raise_error role_error }
      end
    end

    context 'when valid' do
      let(:new_name) { 'new_name' }
      before { instance.name = new_name }
      it { expect { instance.save }.to_not raise_error }
      its(:name) { should eq new_name }
    end
  end

  describe '#delete' do
    subject(:instance) { role.new(id: 1) }

    context 'when invalid' do
      context 'when role not existed' do
        it { expect { role.new(id: nil).delete }.to raise_error role_error }
        it { expect { role.new(id: '').delete }.to raise_error role_error }
        it { expect { role.new(id: 123_456_789).delete }.to raise_error role_error }
      end
    end

    context 'when valid' do
      it { expect { instance.delete }.to_not raise_error }
    end
  end

  describe '#add_privileges!' do
    let(:privileges) {}
    let(:expected_payload) { { privilege_ids: privileges } }
    let(:instance) { described_class.new(id: 1) }
    let(:privilege) { Volcanic::Authenticator::V1::Privilege }

    subject { instance }

    context 'when success attached privileges to auth service' do
      before { allow(instance).to receive(:perform_post_and_parse).and_return('') }

      context 'when adding by ids' do
        it { expect(instance.add_privileges!(1, 2, [3])).to eq [1, 2, 3] }
      end

      context 'when adding by object' do
        let(:priv1) { privilege.new(id: 1, scope: 'vrn:st:ds:res', allow: true) }
        let(:priv2) { privilege.new(id: 2, scope: 'vrn:st:ds:res', allow: true) }
        let(:priv3) { privilege.new(id: 3, scope: 'vrn:st:ds:res', allow: true) }
        it { expect(instance.add_privileges!(priv1, priv2, [priv3])).to eq [1, 2, 3] }

        context 'when add with both type' do
          it { expect(instance.add_privileges!(1, priv2, [priv3])).to eq [1, 2, 3] }
        end
      end

      context '#privilege_ids returning the new attached ids' do
        before { instance.add_privileges!(1, 2, 3) }
        its(:privilege_ids) { should eq [1, 2, 3] }
      end

      context 'Should only attach the new ids' do
        let(:expected_id_to_be_attach) { 3 }
        let(:expected_payload) { { 'privilege_ids': [expected_id_to_be_attach] } }
        let(:instance) { described_class.new(id: 1, privilege_ids: [1, 2]) }
        before { allow(instance).to receive(:perform_post_and_parse).with(anything, anything, expected_payload).and_return('') }

        its(:privilege_ids) { should eq [1, 2] } # current privilege_ids attached
        it { expect(instance.add_privileges!(2)).to eq [1, 2] }
        it { expect(instance.add_privileges!(2, expected_id_to_be_attach)).to eq [1, 2, expected_id_to_be_attach] }
      end
    end

    context 'when failed to attach to auth service' do
      before { allow(instance).to receive(:perform_post_and_parse).and_raise(role_error) }

      it { expect { instance.add_privileges!(1, 2) }.to raise_error role_error }
    end
  end
end
