# frozen_string_literal: true

require 'grpc_mock/matchers/request_including_matcher'

RSpec.describe GrpcMock::Matchers::RequestIncludingMatcher do
  let(:matcher) do
    described_class.new(values)
  end

  let(:values) do
    { key: 'value' }
  end

  it { expect(matcher == { 'key' => 'value', key2: 'value' }).to eq(true) }
  it { expect(matcher == { key: 'value', key2: 'value' }).to eq(true) }
  it { expect(matcher == { key2: 'value' }).to eq(false) }

  context 'when nested values' do
    let(:values) do
      { key: { inner_key: 'value' }, key2: { key3: { key4: 'value' } } }
    end

    it 'reutrn ture' do
      actual = { key10: 10, key: { inner_key: 'value' }, key2: { key3: { key4: 'value' } } }
      expect(matcher == actual).to eq(true)
    end

    it 'reutrn false' do
      actual = { key10: 10, key: { inner_key: 'value' }, key2: { key3: { key3: 'value' } } }
      expect(matcher == actual).to eq(false)
    end
  end
end
