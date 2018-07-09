require 'examples/hello/hello_client'

RSpec.describe GrpcMock do
  describe '.enable!' do
    let(:client) do
      HelloClient.new
    end

    before do
      described_class.disable_net_connect!
      described_class.enable!
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
end
