# frozen_string_literal: true

RSpec.describe GrpcMock::RequestStub do
  let(:stub_request) do
    described_class.new(path)
  end

  let(:path) do
    '/service_name/method_name'
  end

  describe '#response' do
    let(:exception) { StandardError.new }
    let(:request1) { :request_1 }
    let(:request2) { :request_2 }
    let(:value1) { :response_1 }
    let(:value2) { :response_2 }
    let(:value3) { :response_3 }

    it 'returns response' do
      stub_request.to_return(value1)
      expect(stub_request.response.evaluate(request1)).to eq(value1)
    end

    it 'raises exception' do
      stub_request.to_raise(exception)
      expect { stub_request.response.evaluate(request1) }.to raise_error(StandardError)
    end

    it 'returns responses in a sequence passed as array' do
      stub_request.to_return(value1, value2)
      expect(stub_request.response.evaluate(request1)).to eq(value1)
      expect(stub_request.response.evaluate(request1)).to eq(value2)
    end

    it 'returns responses in a sequence passed as array with multiple to_return calling' do
      stub_request.to_return(value1, value2)
      stub_request.to_return(value3)
      expect(stub_request.response.evaluate(request1)).to eq(value1)
      expect(stub_request.response.evaluate(request1)).to eq(value2)
      expect(stub_request.response.evaluate(request1)).to eq(value3)
    end

    it 'repeats returning last response' do
      stub_request.to_return(value1, value2)
      expect(stub_request.response.evaluate(request1)).to eq(value1)
      expect(stub_request.response.evaluate(request1)).to eq(value2)
      expect(stub_request.response.evaluate(request1)).to eq(value2)
      expect(stub_request.response.evaluate(request1)).to eq(value2)
    end

    it 'repeats running last response' do
      stub_request.to_return(value1, value2) do |req|
        case req
        when request1; value1
        when request2; value2
        else; value3
        end
      end
      expect(stub_request.response.evaluate(request2)).to eq(value1)
      expect(stub_request.response.evaluate(request1)).to eq(value2)
      expect(stub_request.response.evaluate(request2)).to eq(value2)
      expect(stub_request.response.evaluate(request1)).to eq(value1)
      expect(stub_request.response.evaluate(request2)).to eq(value2)
    end

    context 'when not calling #to_return' do
      it 'raises an error' do
        expect { stub_request.response }.to raise_error(GrpcMock::NoResponseError)
      end
    end
  end

  describe '#to_return' do
    let(:response) { double(:response) }

    it 'registers response' do
      expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value]).once
      expect(stub_request.to_return(response)).to eq(stub_request)
    end

    it 'registers multi responses' do
      expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::Value, GrpcMock::Response::Value]).once
      expect(stub_request.to_return(response, response)).to eq(stub_request)
    end
  end

  describe '#to_raise' do
    context 'with string' do
      let(:exception) { 'string' }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(stub_request.to_raise(exception)).to eq(stub_request)
      end
    end

    context 'with class' do
      let(:response) { StandardError }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(stub_request.to_raise(response)).to eq(stub_request)
      end
    end

    context 'with exception instance' do
      let(:response) { StandardError.new('message') }
      it 'registers exception' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue]).once
        expect(stub_request.to_raise(response)).to eq(stub_request)
      end
    end

    context 'with invalid value (integer)' do
      let(:response) { 1 }
      it 'raises ArgumentError' do
        expect { stub_request.to_raise(response) }.to raise_error(ArgumentError)
      end
    end

    context 'with multi exceptions' do
      let(:exception) { StandardError.new('message') }
      it 'registers exceptions' do
        expect(GrpcMock::ResponsesSequence).to receive(:new).with([GrpcMock::Response::ExceptionValue, GrpcMock::Response::ExceptionValue]).once
        expect(stub_request.to_raise(exception, exception)).to eq(stub_request)
      end
    end
  end

  describe '#match?' do
    it { expect(stub_request.match?(path, double(:request))).to eq(true) }
  end
end
