# frozen_string_literal: true

require 'examples/hello/hello_client'
require 'examples/request/request_services_pb'

RSpec.describe GrpcMock do
  let(:client) do
    HelloClient.new
  end

  around do |blk|
    described_class.enable!
    blk.call
    described_class.disable!
    described_class.reset!
  end

  describe '.enable!' do
    around do |blk|
      described_class.disable_net_connect!
      blk.call
      described_class.allow_net_connect!
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
    context 'with to_return' do
      let(:response) { Hello::HelloResponse.new(msg: 'test') }

      before do
        described_class.enable!
        GrpcMock.stub_request('/hello.hello/Hello').to_return(response)
      end

      it { expect(client.send_message('hello!')).to eq(response) }
    end

    context 'with to_return with block' do
      let(:response) { Hello::HelloResponse.new(msg: 'test') }

      before do
        described_class.enable!
        GrpcMock.stub_request('/hello.hello/Hello').to_return do |request|
          expect(request.msg).to eq('hello!')
          response
        end
      end

      it { expect(client.send_message('hello!')).to eq(response) }
    end

    context 'with to_return with metadata' do
      let(:response) { Hello::HelloResponse.new(msg: 'test') }

      before do
        described_class.enable!
        GrpcMock.stub_request('/hello.hello/Hello').to_return do |request, call|
          expect(request.msg).to eq('hello!')
          expect(call.metadata).to eq({ 'foo' => 'bar' })
          response
        end
      end

      it { expect(client.send_message('hello!', metadata: { foo: 'bar' })).to eq(response) }
    end

    context 'with to_raise' do
      let(:exception) { StandardError.new('message') }

      before do
        described_class.enable!
        GrpcMock.stub_request('/hello.hello/Hello').to_raise(exception)
      end

      it { expect { client.send_message('hello!') }.to raise_error(exception.class) }
    end

    context 'with to_return with raising block' do
      let(:exception) { StandardError.new('message') }

      before do
        described_class.enable!
        GrpcMock.stub_request('/hello.hello/Hello').to_return do |_request|
          expect(request.msg).to eq('hello!')
          raise exception
        end
      end

      it { expect { client.send_message('hello!') }.to raise_error(exception.class) }
    end
  end

  describe '.with' do
    let(:response) do
      Hello::HelloResponse.new(msg: 'test')
    end

    context 'with equal request' do
      before do
        GrpcMock.stub_request('/hello.hello/Hello').with(Hello::HelloRequest.new(msg: 'hello2!')).to_return(response)
      end

      it { expect(client.send_message('hello2!')).to eq(response) }

      context 'and they are two mocking request' do
        let(:response2) do
          Hello::HelloResponse.new(msg: 'test')
        end

        before do
          GrpcMock.stub_request('/hello.hello/Hello').with(Hello::HelloRequest.new(msg: 'hello2!')).to_return(response2)
        end

        it 'returns newest result' do
          expect(client.send_message('hello2!')).to eq(response2)
        end
      end
    end

    context 'with not equal request' do
      before do
        GrpcMock.stub_request('/hello.hello/Hello').with(Hello::HelloRequest.new(msg: 'hello!')).to_return(response)
      end

      it { expect { client.send_message('hello2!') }.to raise_error(GRPC::Unavailable) }
    end
  end

  describe '#request_including' do
    let(:response) do
      Hello::HelloResponse.new(msg: 'test')
    end

    context 'with equal request' do
      before do
        GrpcMock.stub_request('/hello.hello/Hello').with(GrpcMock.request_including(msg: 'hello2!')).to_return(response)
      end

      it { expect(client.send_message('hello2!')).to eq(response) }
    end

    context 'more complex example' do
      let(:client) do
        Request::Request::Stub.new('localhost:8000', :this_channel_is_insecure)
      end

      let(:response) do
        Request::HelloResponse.new(msg: 'test')
      end

      let(:request) do
        Request::HelloRequest.new(
          msg: 'hello2!',
          n: 10,
          ptype: Request::PhoneType::MOBILE,
          inner: Request::InnerRequest.new(
            msg: 'hello!',
            n: 11,
            ptype: Request::PhoneType::WORK,
          ),
        )
      end

      it 'returns mock object' do
        GrpcMock.stub_request('/request.request/Hello').with(GrpcMock.request_including(msg: 'hello2!')).to_return(response)
        expect(client.hello(request)).to eq(response)
      end

      it 'returns mock object' do
        h = { msg: 'hello2!', ptype: Request::PhoneType.lookup(Request::PhoneType::MOBILE), inner: { msg: 'hello!' } }
        GrpcMock.stub_request('/request.request/Hello').with(GrpcMock.request_including(h)).to_return(response)
        expect(client.hello(request)).to eq(response)
      end
    end

    context 'with not equal request' do
      before do
        GrpcMock.stub_request('/hello.hello/Hello').with(GrpcMock.request_including(msg: 'hello!')).to_return(response)
      end

      it { expect { client.send_message('hello2!') }.to raise_error(GRPC::Unavailable) }
    end
  end
end
