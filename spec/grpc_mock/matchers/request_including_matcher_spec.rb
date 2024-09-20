# frozen_string_literal: true

require 'grpc_mock/matchers/request_including_matcher'
require 'examples/request/request_services_pb'

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

  context 'actual is hello request' do
    context 'ptype is enum 0' do
      let(:actual) { ::Request::HelloRequest.new(msg: "hello2!", inner: ::Request::InnerRequest.new(msg: "hello!", n: 11, ptype: :WORK), n: 10, ptype: :MOBILE) }
      let(:values) { {"inner"=>{"msg"=>"hello!"}, "msg"=>"hello2!", "ptype"=>:MOBILE} }

      it 'return true' do
        expect(matcher == actual).to eq(true)
      end
    end
  end
end
