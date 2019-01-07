require 'examples/hello/hello_client'

RSpec.describe GrpcMock do
  let(:client) do
    HelloClient.new
  end

  around do |blk|
    described_class.enable!
    blk.call
    described_class.disable!
  end

  describe '.enable!' do
    before do
      described_class.disable_net_connect!
    end

    it { expect { client.send_message('hello!') } .to raise_error(GrpcMock::NetConnectNotAllowedError) }

    context 'to GrpcMock.diable!' do
      before do
        described_class.disable!
      end

      it { expect { client.send_message('hello!') } .to raise_error(GRPC::Unavailable) }

      context 'to GrpcMock.enable!' do
        before do
          described_class.enable!
        end

        it { expect { client.send_message('hello!') } .to raise_error(GrpcMock::NetConnectNotAllowedError) }
      end
    end
  end

  describe '.stub_request' do
    let(:response) do
      Hello::HelloResponse.new(msg: 'test')
    end

    before do
      described_class.enable!
      GrpcMock.stub_request('/hello.hello/Hello').to_return(response)
    end

    it { expect(client.send_message('hello!')).to eq(response) }
  end
end
