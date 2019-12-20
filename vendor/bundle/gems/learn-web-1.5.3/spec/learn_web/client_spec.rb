require 'json'

RSpec.describe LearnWeb::Client do
  context "Constants" do
    it "sets the LEARN_URL to learn.co" do
      expect(LearnWeb::Client::LEARN_URL).to eq("https://learn.co")
    end

    it "sets the API_ROOT to the root" do
      expect(LearnWeb::Client::API_ROOT).to eq("/api/v1")
    end
  end

  context "Adding an ssh key" do
    let(:headers) { {} }
    let(:params) { {} }
    let(:req_double) { double("request double", headers: headers, params: params) } # Faraday's weird api 
    let(:web_client) { double }
    let(:client) { LearnWeb::Client.new(token: "mytoken") }

    before do
      allow(req_double).to receive(:url).with("/api/v1/ssh_keys")
    end

    it "correctly makes the request" do
      expect(web_client).to receive(:post)
        .and_yield(req_double)
        .and_return(double(status: 200, body: {message: "Success"}.to_json))
      client.add_ssh_key(key: "a valid ssh key", key_title: "LearnWeb Test Suite", client: web_client)

      expect(headers).to eq({"Authorization"=>"Bearer mytoken"})
      expect(params).to eq({"key"=>"a valid ssh key", :key_title=>"LearnWeb Test Suite"})
    end

    it "does not send a key title if not provided" do
      expect(web_client).to receive(:post)
        .and_yield(req_double)
        .and_return(double(status: 200, body: {message: "Success"}.to_json))

      client.add_ssh_key(key: "a valid ssh key", client: web_client)

      expect(headers).to eq({"Authorization"=>"Bearer mytoken"})
      expect(params).to eq({"key"=>"a valid ssh key"})
    end
    
    it "prints info on 304" do
      expect(web_client).to receive(:post)
        .and_yield(req_double)
        .and_return(double(status: 304, body: {message: "womp"}.to_json))
      expect do
        client.add_ssh_key(key: "a valid ssh key", client: web_client)
      end.to output("This key is already in use.\n").to_stdout

    end
    it "prints info on 422" do
      expect(web_client).to receive(:post)
        .and_yield(req_double)
        .and_return(double(status: 422, body: {message: "womp"}.to_json))
      expect do
        client.add_ssh_key(key: "a valid ssh key", client: web_client)
      end.to output("Something went wrong. Please try again.\n").to_stdout
    end

    it "prints info on anything else" do
      expect(web_client).to receive(:post)
        .and_yield(req_double)
        .and_return(double(status: 418, body: {message: "womp"}.to_json))
      expect do
        client.add_ssh_key(key: "a valid ssh key", client: web_client)
      end.to output("Something went wrong. Please try again.\n").to_stdout
    end
  end
end
