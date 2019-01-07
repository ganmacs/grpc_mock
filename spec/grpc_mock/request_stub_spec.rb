RSpec.describe GrpcMock::RequestStub do
  let(:stub_request) do
    described_class.new(path)
  end

  let(:path) do
    '/service_name/method_name'
  end

  describe '#response' do
    let(:r1) { double(:r1) }
    let(:r2) { double(:r2) }
    let(:r3) { double(:r3) }

    it 'returns response' do
      stub_request.to_return(r1)
      expect(stub_request.response).to eq(r1)
    end

    it 'returns responses in a sequence passed as array' do
      stub_request.to_return(r1, r2)
      expect(stub_request.response).to eq(r1)
      expect(stub_request.response).to eq(r2)
    end

    it 'returns responses in a sequence passed as array with multiple to_return calling' do
      stub_request.to_return(r1, r2)
      stub_request.to_return(r3)
      expect(stub_request.response).to eq(r1)
      expect(stub_request.response).to eq(r2)
      expect(stub_request.response).to eq(r3)
    end

    it 'repeats returning last response' do
      stub_request.to_return(r1, r2)
      expect(stub_request.response).to eq(r1)
      expect(stub_request.response).to eq(r2)
      expect(stub_request.response).to eq(r2)
      expect(stub_request.response).to eq(r2)
    end

    context 'when not calling #to_return' do
      it 'raises an error' do
        expect { stub_request.response }.to raise_error(GrpcMock::NoResponseError)
      end
    end
  end

  describe '#to_return' do
    it 'registers response' do
      request = double(:request)
      expect(GrpcMock::ResponsesSequence).to receive(:new).with([request]).once
      expect(stub_request.to_return(request)).to eq(stub_request)
    end

    it 'registers multi responses' do
      request = double(:request)
      expect(GrpcMock::ResponsesSequence).to receive(:new).with([request, request]).once
      expect(stub_request.to_return(request, request)).to eq(stub_request)
    end
  end

  describe '#match?' do
    it { expect(stub_request.match?(path, double(:request))).to eq(true) }
  end
end
