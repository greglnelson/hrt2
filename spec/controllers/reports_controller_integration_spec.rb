require 'spec_helper'

describe ReportsController do
  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :index end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access this page") }
    end
  end

  context "as a reporter" do
    before :each do
      @req = Factory :data_request
      @reporter = Factory :reporter
      login @reporter
    end

    it "should render index" do
      get :index
      response.should be_success
      assigns[:current_response].should == @reporter.current_response
    end

    it "should initialize an org report presenter" do
      get :index
      assigns[:report].should_not be_nil
    end
  end
end