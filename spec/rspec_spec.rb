# frozen_string_literal: true

require 'spec_helper'
require 'examples/hello/hello_client'

RSpec.describe 'grpc_mock/rspec' do
  require 'grpc_mock/rspec'

  before do
    GrpcMock.enable!
    GrpcMock.allow_net_connect!
  end

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

      context 'change disable -> allow -> disable ' do
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
      end
    end
  end

  context 'disable_net_connect with exception for localhost' do
    before do
      GrpcMock.disable_net_connect!(allow_localhost: true)
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

    context 'but client does not reference localhost' do
      let(:client) do
        HelloClient.new('example.com:8000')
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
    end
  end

  context 'disable_net_connect with allow specified' do
    before do
      GrpcMock.disable_net_connect!(allow: allow_list)
    end

    let(:client) do
      HelloClient.new('example.com:8000')
    end

    context 'as nil' do
      let(:allow_list) { nil }

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
    end

    context 'as empty array' do
      let(:allow_list) { [] }

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
    end

    context 'as string' do
      let(:allow_list) { 'example.com' }

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

      context 'with a port' do
        let(:allow_list) { 'example.com:8000' }

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

      context 'with a non-matching port' do
        let(:allow_list) { 'example.com:8888' }

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
      end

      context 'that does not match' do
        let(:allow_list) { 'exmple.com'}

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
      end
    end

    context 'as array of strings' do
      let(:allow_list) { ['http://example.com', 'foo.com'] }

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

      context 'that does not match' do
        let(:allow_list) { ['exmple.com', 'foo.com'] }

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
      end
    end

    context 'as array of procs' do
      let(:allow_list) { [proc { |uri| uri.host.starts_with?('ex') }] }

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

      context 'that does not match' do
        let(:allow_list) { [proc { |uri| uri.host.starts_with?('ax') }] }

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
      end
    end

    context 'as array of regex' do
      let(:allow_list) { [/ex/, /foo/] }

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

      context 'that does not match' do
        let(:allow_list) { [/ax/, /foo/] }

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
      end
    end
  end
end
