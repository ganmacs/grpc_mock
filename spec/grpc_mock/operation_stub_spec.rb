# frozen_string_literal: true

RSpec.describe GrpcMock::OperationStub do
  subject(:operation) { described_class.new(response: response, metadata: metadata, deadline: deadline) }

  let(:response) { double(:response) }
  let(:metadata) { nil }
  let(:deadline) { nil }

  describe '#execute' do
    subject { operation.execute }

    it { is_expected.to eq response }
  end

  describe '#response' do
    subject { operation.response }

    it { is_expected.to eq response }
  end

  describe '#metadata' do
    subject { operation.metadata }

    it { is_expected.to eq metadata }

    context 'when metadata is provided' do
      let(:metadata) { double(:metadata) }

      it { is_expected.to eq metadata }
    end
  end

  describe '#deadline' do
    subject { operation.deadline }

    it { is_expected.to eq deadline }

    context 'when deadline is provided' do
      let(:deadline) { Time.now.utc + rand(10_000) }

      it { is_expected.to eq deadline }
    end
  end
end
