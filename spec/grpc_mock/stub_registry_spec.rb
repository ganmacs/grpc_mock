RSpec.describe GrpcMock::StubRegistry do
  let(:registry) do
    described_class.new
  end

  let(:request_stub) do
    double(:request_stub, 'match?': true, response: 'response')
  end

  it 'registers and responses' do
    expect(registry.register_request_stub(request_stub)).to eq(request_stub)
    expect(registry.response_for_request('service/method_name', double(:request))).to eq('response')
  end
end
