# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Privilege do
  let(:id) { nil }
  let(:scope) { 'vrn:*:*:*' }
  let(:permission_id) { 1 }
  let(:group_id) { 1 }
  let(:allow) { true }

  let(:params) do
    {
      id: id, scope: scope, permission_id: permission_id,
      group_id: group_id, allow: allow
    }
  end

  subject(:instance) { described_class.new(**params) }

  describe 'sorting' do
    let(:objects) { [first, second] }
    subject(:sorted) { objects.sort }

    context 'when the allows are the same' do
      context 'and the scopes are the same' do
        let(:first) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23') }
        let(:second) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23') }

        it("doesn't change the order") { expect(sorted).to eq([first, second]) }
      end

      context 'and the scopes are the different' do
        let(:first) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23') }
        let(:second) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/*') }

        it('sorts by specificity, widest first') { expect(sorted).to eq([second, first]) }

        context 'but have the same specificity' do
          let(:second) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/9836') }

          it("doesn't change the order") { expect(sorted).to eq([first, second]) }
        end
      end
    end

    context 'when the allows are the different' do
      context 'and the scopes are the same' do
        let(:first) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23') }
        let(:second) { described_class.new(allow: false, scope: 'vrn:eu-2:3:jobs/23') }

        it('sorts by allow, true first') { expect(sorted).to eq([first, second]) }
      end

      context 'and the scopes are the different' do
        let(:first) { described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23') }
        let(:second) { described_class.new(allow: false, scope: 'vrn:eu-2:3:jobs/*') }

        it('sorts by specificity, widest first, ignoring allow') { expect(sorted).to eq([second, first]) }

        context 'but have the same specificity' do
          let(:second) { described_class.new(allow: false, scope: 'vrn:eu-2:3:jobs/9836') }

          it('sorts by allow, true first') { expect(sorted).to eq([first, second]) }
        end
      end
    end

    context 'with multiple privlieges' do
      let(:objects) do
        [
          described_class.new(allow: true, scope: 'vrn:*:*:jobs/*'),
          described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23'),
          described_class.new(allow: true, scope: 'vrn:eu-2:*:jobs/*'),
          described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23?foo=bar'),
          described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/*')
        ]
      end

      it 'sorts an array of Privilege objects by scope, then by allow' do
        expected = [
          'vrn:*:*:jobs/*',
          'vrn:eu-2:*:jobs/*',
          'vrn:eu-2:3:jobs/*',
          'vrn:eu-2:3:jobs/23',
          'vrn:eu-2:3:jobs/23?foo=bar'
        ]
        expect(sorted.map(&:scope)).to eq(expected)
      end
    end

    context 'with multiple privlieges, differing allows' do
      let(:objects) do
        {
          1 => described_class.new(allow: true, scope: 'vrn:*:*:jobs/*'),
          5 => described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23'),
          2 => described_class.new(allow: false, scope: 'vrn:eu-2:*:jobs/*'),
          3 => described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/*'),
          4 => described_class.new(allow: false, scope: 'vrn:eu-2:3:jobs/*')
        }
      end

      let(:sorted) { objects.values.sort }

      it 'sorts by scope, then allow, widest first then true first when matching' do
        expected_order = [1, 2, 3, 4, 5]
        expected = expected_order.map { |item| objects[item] }
        expect(sorted).to eq(expected)
      end
    end
  end

  describe 'method' do
    describe '#initialize' do
      context 'with all required data' do
        it 'assigns correctly' do
          expect(subject.id).to eq(id)
          expect(subject.scope).to eq(scope)
          expect(subject.permission_id).to eq(permission_id)
          expect(subject.group_id).to eq(group_id)
          expect(subject.allow).to eq(allow)
        end
      end

      context 'with missing required data' do
        let(:params) do
          {
            group_id: group_id, allow: allow
          }
        end

        it 'raises an error' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end

    describe '#==' do
      subject { instance == other }
      context 'to nil' do
        let(:other) { nil }
        it { is_expected.to be false }
      end

      context 'to the same object' do
        let(:other) { instance }
        it { is_expected.to be true }
      end

      context 'when all of the values are the same' do
        let(:other) { described_class.new(**other_params) }
        let(:other_params) { params }
        it { is_expected.to be true }

        %i[id permission_id group_id allow].each do |diff|
          context "except the #{diff}" do
            let(:other_params) { params.merge(diff => 'different') }
            it { is_expected.to be false }
          end
        end

        context 'except the scope' do
          let(:other_params) { params.merge(scope: 'vrn:different:scope:for/resource') }
          it { is_expected.to be false }
        end
      end
    end
  end
end
