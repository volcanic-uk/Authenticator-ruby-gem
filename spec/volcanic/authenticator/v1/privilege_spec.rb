# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Privilege do
  let(:id) { nil }
  let(:scope) { '' }
  let(:permission_id) { 1 }
  let(:group_id) { 1 }
  let(:allow) { true }

  let(:params) do
    {
      id: id, scope: scope, permission_id: permission_id,
      group_id: group_id, allow: allow
    }
  end

  subject { described_class.new(params) }

  describe 'sorting' do
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

      let(:sorted) { objects.sort }

      it 'sorts an array of Privilege objects' do
        expect(sorted.map(&:scope)).to eq(['vrn:*:*:jobs/*', 'vrn:eu-2:*:jobs/*', 'vrn:eu-2:3:jobs/*', 'vrn:eu-2:3:jobs/23', 'vrn:eu-2:3:jobs/23?foo=bar'])
      end
    end

    context 'with multiple privlieges, differing allows' do
      let(:objects) do
        [
          described_class.new(allow: true, scope: 'vrn:*:*:jobs/*'),
          described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23'),
          described_class.new(allow: false, scope: 'vrn:eu-2:*:jobs/*'),
          described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23?foo=bar'),
          described_class.new(allow: false, scope: 'vrn:eu-2:3:jobs/*')
        ]
      end

      let(:sorted) { objects.sort }

      it 'sorts an array of Privilege objects' do
        expect(sorted.map(&:scope)).to eq(['vrn:*:*:jobs/*', 'vrn:eu-2:*:jobs/*', 'vrn:eu-2:3:jobs/*', 'vrn:eu-2:3:jobs/23', 'vrn:eu-2:3:jobs/23?foo=bar'])
      end
    end

    context 'two privileges, same scope, different allow' do
      let(:objects) do
        [
          described_class.new(allow: true, scope: 'vrn:eu-2:3:jobs/23'),
          described_class.new(allow: false, scope: 'vrn:eu-2:3:jobs/23')
        ]
      end

      let(:sorted) { objects.sort }

      it 'sorts an array of Privilege objects' do
        expected = sorted.map { |p| [p.scope, p.allow] }
        expect(expected).to eq([['vrn:eu-2:3:jobs/23', true], ['vrn:eu-2:3:jobs/23', false]])
      end
    end

    context 'two privileges, different scopes' do
      let(:objects) do
        [
          described_class.new(allow: false, scope: 'vrn:*:*:jobs/23'),
          described_class.new(allow: true, scope: 'vrn:*:*:jobs/224527')
        ]
      end

      let(:sorted) { objects.sort }

      it 'sorts an array of Privilege objects' do
        expected = sorted.map { |p| [p.scope, p.allow] }
        expect(expected).to eq([['vrn:*:*:jobs/23', false], ['vrn:*:*:jobs/224527', true]])
      end
    end
  end

  describe 'method' do
    describe '#initialise' do
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
  end
end
