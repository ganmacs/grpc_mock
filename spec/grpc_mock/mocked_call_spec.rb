require 'rspec'

RSpec.describe GrpcMock::MockedCall do
  describe "#metadata" do
    it "returns metadata hash" do
      call = GrpcMock::MockedCall.new(metadata: { foo: 'bar' })
      expect(call.metadata).to eq({ 'foo' => 'bar' })
    end
  end

  describe "#sanitize_metadata" do
    def sanitize_metadata(metadata)
      GrpcMock::MockedCall.new(metadata: metadata).metadata
    end

    it "rejects non-Hash argument" do
      expect {
        sanitize_metadata([1, 2, 3])
      }.to raise_error(TypeError)
    end

    it "accepts String and Symbol keys" do
      metadata = {
        :foo => 'bar',
        'hoge' => 'piyo',
      }
      metadata = sanitize_metadata(metadata)
      expect(metadata).to eq({
                               'foo' => 'bar',
                               'hoge' => 'piyo',
                             })
    end

    it "accepts allowed symbols" do
      metadata = {
        :'user-agent' => 'Mozilla',
        'content-type' => 'application/protobuf',
        :'f.o_o' => 'bar',
      }
      metadata = sanitize_metadata(metadata)
      expect(metadata).to eq({
                               'user-agent' => 'Mozilla',
                               'content-type' => 'application/protobuf',
                               'f.o_o' => 'bar',
                             })
    end

    it "rejects non-String non-Symbol keys" do
      expect {
        sanitize_metadata({ 1 => 'bar' })
      }.to raise_error(TypeError)
    end

    it "rejects empty key" do
      expect {
        sanitize_metadata({ "" => 'bar' })
      }.to raise_error(ArgumentError)
    end

    it "rejects capital key name" do
      expect {
        sanitize_metadata({ "FOO" => 'bar' })
      }.to raise_error(ArgumentError)
    end

    it "rejects invalid key format" do
      expect {
        sanitize_metadata({ "foo+" => 'bar' })
      }.to raise_error(ArgumentError)

      expect {
        sanitize_metadata({ :"foo+" => 'bar' })
      }.to raise_error(ArgumentError)
    end

    it "accepts String / Array values" do
      metadata = {
        'string' => 'foo',
        'array' => ['foo'],
        'array-zero' => [],
        'array-multiple' => ['foo', 'bar'],
      }
      metadata = sanitize_metadata(metadata)
      expect(metadata).to eq({
                               'string' => 'foo',
                               'array' => 'foo',
                               'array-multiple' => ['foo', 'bar'],
                             })
    end

    it "rejects non-String non-Array values" do
      expect {
        sanitize_metadata({ 'frob' => :something })
      }.to raise_error(ArgumentError)
    end

    it "rejects non-String elements" do
      expect {
        sanitize_metadata({ 'foo' => [['bar']] })
      }.to raise_error(TypeError)
    end

    it "accepts ascii values" do
      metadata = {
        'string' => "x&(y^z) +: !~`'\"\\",
      }
      metadata = sanitize_metadata(metadata)
      expect(metadata).to eq({
                               'string' => "x&(y^z) +: !~`'\"\\",
                             })
    end

    it "accepts binary values" do
      metadata = {
        'string-bin' => "a\x87b\xA0c\t\n",
      }
      metadata = sanitize_metadata(metadata)
      expect(metadata).to eq({
                               'string-bin' => "a\x87b\xA0c\t\n",
                             })
    end

    it "rejects non-ascii values" do
      expect {
        sanitize_metadata({ 'string' => "foo\n" })
      }.to raise_error(ArgumentError)
    end
  end
end
