# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Role, vcr: { match_requests_on: [:method, :uri]} do
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
end
