# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Principal, :vcr do
  before { Configuration.set }
  let(:principal) { Volcanic::Authenticator::V1::Principal }
  let(:mock_name) { 'mock_name' }
  let(:mock_dataset_id) { 'mock_dataset_id' }
  let(:mock_principal_id) { 'principal_id' }
  let(:mock_roles) { [1, 2] }
  let(:mock_privileges) { [3, 4] }
  let(:principal_error) { Volcanic::Authenticator::V1::PrincipalError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }

  describe '#create' do
    context 'when missing name' do
      it { expect { principal.create(nil, 1) }.to raise_error principal_error }
      it { expect { principal.create('', 1) }.to raise_error principal_error }
    end

    context 'when duplicate name' do
      before { principal.create(mock_name, mock_dataset_id) }
      it { expect { principal.create(mock_name, mock_dataset_id) }.to raise_error principal_error }
    end

    context 'when success' do
      subject { principal.create(mock_name, mock_dataset_id) }
      its(:id) { should eq mock_principal_id }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
    end
  end

  describe '#find' do
    context 'when find by id' do
      subject { principal.find_by_id(mock_principal_id) }
      its(:id) { should eq mock_principal_id }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
    end

    context 'when find with specific page' do
      subject(:principals) { principal.find(page: 2) }
      it { expect(principals[0].id).to eq 11 }
      it { expect(principals.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:principals) { principal.find(page_size: 2) }
      it { expect(principals[0].id).to eq 1 }
      it { expect(principals.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:principals) { principal.find(page: 2, page_size: 3) }
      it { expect(principals[0].id).to eq 4 }
      it { expect(principals.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:principals) { principal.find(query: 'vol') }
      it { expect(principals[0].name).to eq 'volcanic' }
      it { expect(principals[1].name).to eq 'vol' }
    end

    context 'when find with pagination' do
      subject(:principals) { principal.find }
      it { expect(principals.page). to eq 1 }
      it { expect(principals.page_size). to eq 10 }
      it { expect(principals.row_count). to eq 20 }
      it { expect(principals.page_count). to eq 2 }
    end

    context 'when find with name' do
      subject(:principals) { principal.find(name: 'volcanic') }
      it { expect(principals.first.name).to eq 'volcanic' }
    end

    context 'when find with name that has special character' do
      subject(:principals) { principal.find(name: 'volcanic_ý') }
      it { expect(principals.first.name).to eq 'volcanic_ý' }
    end

    context 'when find with name that has + character ' do
      subject(:principals) { principal.find(name: 'volcanic+1234') }
      it { expect(principals.first.name).to eq 'volcanic+1234' }
    end
  end

  describe '#save' do
    let(:instance) { principal.create(mock_name, mock_dataset_id) }

    context 'when invalid' do
      context 'name is nil' do
        before { instance.name = nil }
        it { expect { instance.save }.to raise_error principal_error }
      end

      context 'name is empty' do
        before { instance.name = '' }
        it { expect { instance.save }.to raise_error principal_error }
      end
    end

    context 'when valid' do
      let(:new_name) { 'new_name' }
      before do
        instance.name = new_name
        instance.save
      end
      it { expect(principal.find(query: new_name).first.name).to eq new_name }
    end
  end

  describe '#delete' do
    context 'when invalid' do
      it('non-existed principal') do
        expect { principal.new(id: 'wrong-id').delete }.to raise_error principal_error
        expect { principal.new(id: 123_456_789).delete }.to raise_error principal_error
      end
    end

    context 'when valid' do
      context 'deleted' do
        before { principal.new(id: mock_principal_id).delete }
        it { expect { principal.find_by_id(mock_principal_id) }.to raise_error principal_error }
      end

      context 'create back deleted principal' do
        before do
          # create
          principal.create(mock_name, mock_dataset_id)
          # find and delete
          principal.find(name: mock_name).first.delete
        end

        it { expect { principal.create(mock_name, mock_dataset_id) }.to_not raise_error }
      end
    end
  end

  describe '#update_role_ids' do
    subject(:instance) { principal.create(mock_name, mock_dataset_id) }

    context 'When role id is nil' do
      before { instance.update_role_ids(nil) }
      its(:role_ids) { should eq [] }
    end

    context 'When updating with integer and strings' do
      before { instance.update_role_ids(1, '2') }
      its(:role_ids) { should eq [1, 2] }
    end

    context 'When updating with array value' do
      before { instance.update_role_ids([1, 2]) }
      its(:role_ids) { should eq [1, 2] }
    end

    context 'When updating with empty array' do
      before { instance.update_role_ids([]) }
      its(:role_ids) { should eq [] }
    end
  end

  describe '#update_privilege_ids' do
    subject(:instance) { principal.create(mock_name, mock_dataset_id) }

    context 'When role id is nil' do
      before { instance.update_privilege_ids(nil) }
      its(:privilege_ids) { should eq [] }
    end

    context 'When updating with integer and strings' do
      before { instance.update_privilege_ids(1, '2') }
      its(:privilege_ids) { should eq [1, 2] }
    end

    context 'When updating with array value' do
      before { instance.update_privilege_ids([1, 2]) }
      its(:privilege_ids) { should eq [1, 2] }
    end

    context 'When updating with empty array' do
      before { instance.update_privilege_ids([]) }
      its(:privilege_ids) { should eq [] }
    end
  end

  describe '#deactivate!' do
    subject(:instance) { principal.create(mock_name, mock_dataset_id) }

    context 'when valid' do
      it { expect { instance.deactivate! }.not_to raise_error }
    end

    context 'when invalid' do
      context 'already been deactivated' do
        before { instance.deactivate! }
        it { expect { instance.deactivate! }.to raise_error principal_error }
      end

      context 'not existed' do
        before { instance.id = 'wrong-id' }
        it { expect { instance.deactivate! }.to raise_error principal_error }
      end
    end
  end

  describe '#activate!' do
    subject(:instance) { principal.create(mock_name, mock_dataset_id) }

    context 'when valid' do
      context 'already been activated' do
        it { expect { instance.activate! }.not_to raise_error }
      end

      context 'already been deactivated' do
        before { instance.deactivate! }
        it { expect { instance.activate! }.not_to raise_error }
      end
    end

    context 'when invalid' do
      context 'not existed' do
        before { instance.id = 'wrong-id' }
        it { expect { instance.activate! }.to raise_error principal_error }
      end
    end
  end
end
