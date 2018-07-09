require 'spec_helper'
require 'examples/hello/hello_client'

RSpec.describe 'grpc_mock/rspec' do
  require 'grpc_mock/rspec'

  let(:client) do
    HelloClient.new
  end

  context 'when request_response' do
    it { expect { client.send_message('hello!') } .to raise_error(GRPC::Unavailable) }
  end

  context 'when server_stream' do
    it { expect { client.send_message('hello!', server_stream: true) }.to raise_error(GRPC::Unavailable) }
  end

  context 'when client_stream' do
    it { expect { client.send_message('hello!', client_stream: true) }.to raise_error(GRPC::Unavailable) }
  end

  context 'when bidi_stream' do
    it { expect { client.send_message('hello!', client_stream: true, server_stream: true) }.to raise_error(GRPC::Unavailable) }
  end

  context 'disable_net_connect!' do
    before do
      GrpcMock.disable_net_connect!
    end

    context 'when request_response' do
      it { expect { client.send_message('hello!') } .to raise_error(GrpcMock::NetConnectNotAllowedError) }
    end

    context 'when server_stream' do
      it { expect { client.send_message('hello!', server_stream: true) }.to raise_error(GrpcMock::NetConnectNotAllowedError) }
    end

    context 'when client_stream' do
      it { expect { client.send_message('hello!', client_stream: true) }.to raise_error(GrpcMock::NetConnectNotAllowedError) }
    end

    context 'when bidi_stream' do
      it { expect { client.send_message('hello!', client_stream: true, server_stream: true) }.to raise_error(GrpcMock::NetConnectNotAllowedError) }
    end

    # should be in disable_net_connect! context
    context 'allow_net_connect!' do
      before do
        GrpcMock.allow_net_connect!
      end

      context 'when request_response' do
        it { expect { client.send_message('hello!') } .to raise_error(GRPC::Unavailable) }
      end

      context 'when server_stream' do
        it { expect { client.send_message('hello!', server_stream: true) }.to raise_error(GRPC::Unavailable) }
      end

      context 'when client_stream' do
        it { expect { client.send_message('hello!', client_stream: true) }.to raise_error(GRPC::Unavailable) }
      end

      context 'when bidi_stream' do
        it { expect { client.send_message('hello!', client_stream: true, server_stream: true) }.to raise_error(GRPC::Unavailable) }
      end
    end
  end
end
