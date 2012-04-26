require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:organization) }
    it { should allow_mass_assignment_of(:roles) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:location_id) }
  end

  describe "Associations" do
    it { should have_many :comments }
    it { should have_many :data_responses }
    it { should belong_to :organization }
    it { should have_and_belong_to_many :organizations }
    it { should belong_to :location }
  end

  describe "Validations" do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization_id) }

    context "should not validate the presence of a location id if the user is not an activity manager" do
      subject { Factory(:reporter) }
      it { should_not validate_presence_of(:location_id)}
    end

    context "existing record in db" do
      subject { Factory(:reporter, :organization => Factory(:organization) ) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end

    it "cannot assign blank role" do
      user = Factory.build(:reporter, :roles => [])
      user.save
      user.errors.on(:roles).should include('is not included in the list')
    end

    it "cannot assign unexisting role" do
      user = Factory.build(:reporter, :roles => ['admin123'])
      user.save
      user.errors.on(:roles).should include('is not included in the list')
    end
  end

  it "notifies organization it needs to create responses" do
    u = Factory.build :reporter
    org = u.organization
    u.should_receive(:create_organization_responses).once
    u.run_callbacks(:after_create)
  end

  describe "save and invite" do
    before :each do
      @sysadmin = Factory(:sysadmin)

    end
    it "does not send an invite if the user is not valid" do
      @user = Factory.build(:reporter, :email => nil, :full_name => nil, :organization => nil)
      @user.save_and_invite(@sysadmin).should be_nil
      User.all.count.should == 1
    end

    it "sends an invite if hte user is valid" do
      @user = Factory.build(:reporter)
      @user.save_and_invite(@sysadmin).should be_true
      User.count.should == 2
    end
  end

  describe "password validations" do
    before :each do
      @user = User.new(:email => 'blah@blah.com', :full_name => 'blah',
                       :password => "", :password_confirmation => "", :organization => Factory(:organization),
                       :roles => ['reporter'])
    end

    # this is fine provided you send an invitation too!!
    it "should not ask on (admin) creation" do
      @user.save.should == true
    end

    it "should reject empty pw on registration" do
      @user.save
      @user.attributes = {"password"=>"", "password_confirmation"=>""}
      @user.activate.should == false
      @user.errors.on(:password).should == "is too short (minimum is 6 characters)"
    end

    it "should reject short pw on registration" do
      @user.save
      @user.password = "123"; @user.password_confirmation = "123"
      @user.activate.should == false
      @user.errors.on(:password).should == "is too short (minimum is 6 characters)"
    end

    it "should accept valid pw on registration" do
      @user.save
      @user.password = "123456"; @user.password_confirmation = "123456"
      @user.activate.should == true
    end

    it "should validate on update if modified" do
      @user.save
      @user.password = "123456"; @user.password_confirmation = "123456"
      @user.activate.should == true
      @user.password = ""; @user.password_confirmation = ""
      @user.full_name = "new name"
      @user.save.should == false
      @user.errors.on(:password_confirmation).should == "is too short (minimum is 6 characters)"
    end

    it "should not validate on update if not modified" do
      @user.save
      @user.password = "123456"; @user.password_confirmation = "123456"
      @user.activate.should == true
      @user.reload
      params = {"full_name"=>"new name", "password"=>"", "password_confirmation"=>"",
        "email"=>'blah@blah.com', "tips_shown"=>"1"}
      User.first.update_attributes(params).should == true
    end

    it "should reject short pw on update" do
      @user.save
      @user.password = "123456"; @user.password_confirmation = "123456"
      @user.activate.should == true
      @user.password = "123"; @user.password_confirmation = "123"
      @user.save.should == false
      @user.errors.on(:password).should == "is too short (minimum is 6 characters)"
    end
  end

  describe "passwords using save & invite API" do
    before :each do
      @user = User.new(:email => 'blah@blah.com', :full_name => 'blah',
                       :password => "", :password_confirmation => "", :organization => Factory(:organization),
                       :roles => ['reporter'])
      @user.save_and_invite(Factory :admin)
    end

    it "should allow (admin) to create a user w/out a password" do
      @user.id.should_not be_nil #was saved
    end

    it "should allow (admin) to update a user before they have registered" do
      @user.full_name = "bob rob"
      @user.save.should == true
    end

    it "should NOT allow (user) to accept invitation (go active) w/out a password" do
      @user.activate.should == false
      @user.errors.on(:password).should == "is too short (minimum is 6 characters)"
    end

    it "should NOT allow (user) to accept invitation (go active) with a short password" do
      @user.password = '123'
      @user.password_confirmation = '123'
      @user.activate.should == false
      @user.errors.on(:password).should == "is too short (minimum is 6 characters)"
    end

    it "should allow (user) to accept invitation (go active) with a good password" do
      @user.password = '123456'
      @user.password_confirmation = '123456'
      @user.activate.should == true
    end
  end

  describe "roles" do
    it "is sysadmin when has admin role" do
      user = Factory(:user, :roles => ['admin'])
      user.sysadmin?.should be_true
    end

    it "is reporter when has reporter role" do
      user = Factory(:user, :roles => ['reporter'])
      user.reporter?.should be_true
    end

    it "is activity_manager when has activity_manager role" do
      user = Factory(:user, :roles => ['activity_manager'])
      user.activity_manager?.should be_true
    end

    it "is admin when roles_mask = 1" do
      user = Factory(:user, :roles => ['admin'])
      user.roles.should == ['admin']
      user.roles_mask.should == 1
    end

    it "is reporter when roles_mask = 2" do
      user = Factory(:user, :roles => ['reporter'])
      user.roles.should == ['reporter']
      user.roles_mask.should == 2
    end

    it "is admin and reporter when roles_mask = 3" do
      user = Factory(:user, :roles => ['admin', 'reporter'])
      user.roles.should == ['admin', 'reporter']
      user.roles_mask.should == 3
    end

    it "is activity_manager when roles_mask = 4" do
      user = Factory(:user, :roles => ['activity_manager'])
      user.roles.should == ['activity_manager']
      user.roles_mask.should == 4
    end

    it "is admin and activity_manager when roles_mask = 5" do
      user = Factory(:user, :roles => ['admin', 'activity_manager'])
      user.roles.should == ['admin', 'activity_manager']
      user.roles_mask.should == 5
    end

    it "is reporter and activity_manager when roles_mask = 6" do
      user = Factory(:user, :roles => ['reporter', 'activity_manager'])
      user.roles.should == ['reporter', 'activity_manager']
      user.roles_mask.should == 6
    end

    it "is admin, reporter and activity_manager when roles_mask = 7" do
      user = Factory(:user, :roles => ['admin', 'reporter', 'activity_manager'])
      user.roles.should == ['admin', 'reporter', 'activity_manager']
      user.roles_mask.should == 7
    end
  end

  describe "roles= can be assigned" do
    it "can assign 1 role" do
      user = Factory(:reporter)
      user.roles = ['admin']
      user.save
      user.reload.roles.should == ['admin']
    end

    it "can assign 3 roles" do
      user = Factory(:reporter)
      user.roles = ['admin', 'reporter', 'activity_manager']
      user.save
      user.reload.roles.should == ['admin', 'reporter', 'activity_manager']
    end
  end

  describe "role change" do
    it "removed organizations when role is changed from activity_manager to else" do
      org1 = Factory(:organization)
      org2 = Factory(:organization)
      user = Factory(:activity_manager, :organizations => [org1, org2])
      user.roles = ['reporter']
      user.save
      user.organizations.should be_empty
    end
  end
end
