require 'spec_helper'

describe DashboardController do
  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :index end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access this page") }
    end
  end

  context "as a reporter" do
    before :each do
      @organization = Factory(:organization)
      @data_request = Factory(:data_request, :organization => @organization) # we need a request in the system first
      @reporter = Factory.create(:reporter) # auto-assigns current response
      @data_request = Factory(:data_request, :organization => @organization) # a newer request, so we get a flash
      login @reporter
    end

    describe "GET 'index'" do
      it "should be successful" do
        Document.stub_chain(:visible_to_reporters, :latest_first, :limited).and_return([])
        Document.should_receive(:visible_to_reporters).once
        get 'index'
        response.should be_success
      end
    end
  end

  context "as an activity manager" do
    before :each do
      @organization = Factory(:organization)
      @data_request = Factory(:data_request, :organization => @organization) # we need a request in the system first
      @activity_manager = Factory.create(:activity_manager, :organization => @organization) # side effect - creates a response/request
      @data_request = Factory(:data_request, :organization => @organization) # a newer request, so we get a flash
      login @activity_manager
    end

    describe "GET 'index'" do
      it "should be successful" do
        get 'index'
        response.should be_success
      end
    end
  end

  context "as an admin" do
    before :each do
      @organization = Factory(:organization)
      @data_request = Factory(:data_request, :organization => @organization) # we need a request in the system first
      @admin = Factory.create(:admin)
      login @admin
    end

    it "should be successful" do
      Document.stub_chain(:latest_first, :limited).and_return([])
      Document.should_receive(:latest_first).once
      get 'index'
      response.should be_success
    end
  end
end
