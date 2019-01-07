# frozen_string_literal: true

RSpec.describe GrpcMock::RequestPattern do
  let(:request_pattern) do
    described_class.new(path)
  end

  let(:path) do
    'test_path'
  end

  describe '#with' do
    context 'with no argument' do
      it 'raises an error' do
        expect { request_pattern.with }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'match?' do
    let(:request) do
      double(:request)
    end

    it { expect(request_pattern.match?(path, request)).to eq(true) }

    context 'when call with' do
      it 'reutrns true' do
        request_pattern.with(request)
        expect(request_pattern.match?(path, request)).to eq(true)
      end

      context 'when request is not same value' do
        it 'reutrns false' do
          request_pattern.with(double(:request1))
          expect(request_pattern.match?(path, request)).to eq(false)
        end
      end

      context 'with block returning ture' do
        it 'reutrns false' do
          request_pattern.with(request) { |_| true }
          expect(request_pattern.match?(path, request)).to eq(true)
        end
      end

      context 'with block returning false' do
        it 'reutrns false' do
          request_pattern.with(request) { |_| false }
          expect(request_pattern.match?(path, request)).to eq(false)
        end
      end
    end
  end
end
