Feature: Admin can manage users
  In order to track information
  As an admin
  I want to be able to manage users

  Background:
    Given an organization exists with name: "organization1"
    And an admin exists with email: "sysadmin@hrtapp.com", organization: the organization
    And I am signed in as "sysadmin@hrtapp.com"

  Scenario: Admin can CRUD users
    When I follow "Users"
    And I follow "Create User"
    And I select "organization1" from "Organization"
    And I fill in "Email" with "pink.panter1@hrtapp.com"
    And I fill in "Full name" with "Pink Panter"
    And I select "Reporter" from "Assign roles to this user"
    And I press "Create New User"
    Then I should see "User was successfully created"
    And "pink.panter1@hrtapp.com" should receive an email
    And I should see "organization1"
    And I should see "pink.panter1@hrtapp.com"
    And I should see "Pink Panter"
    When I follow "Pink Panter"
    And I fill in "Email" with "pink.panter2@hrtapp.com"
    And I press "Update User"
    Then I should see "User was successfully updated"
    And the "Email" field should contain "pink.panter2@hrtapp.com"
    When I follow "Delete this User"
    Then I should see "User was successfully destroyed"
    And I should not see "pink.panter1"
    And I should not see "pink.panter2"

  Scenario: SysAdmin can invite user and user can accept invitation
    When I follow "Users"
      And I follow "Create User"
      And I select "organization1" from "Organization"
      And I fill in "Email" with "pink.panter1@hrtapp.com"
      And I fill in "Full name" with "Pink Panter"
      And I select "Reporter" from "Assign roles to this user"
      And I press "Create New User"
    Then I should see "User was successfully created"
      And "pink.panter1@hrtapp.com" should receive an email
    And I follow "Sign Out"
    Then I should see "Signed out successfully"

    # login with other user
    When I open the email with subject "[Health Resource Tracker] You have been invited to HRT"
      And I follow "invitations" in the email
      And I fill in "Password" with "password" within "#invitation_form"
      And I fill in "Password confirmation" with "password" within "#invitation_form"
      And I press "Save" within "#invitation_form"
    Then I should be on the dashboard page


  Scenario: Admin can see last login
    Given now is "01-01-2011 21:30:00 +0000"
    Given a basic reporter setup with org "org2"
    When I follow "Sign Out"
      And I am signed in as "reporter@hrtapp.com"
      And I follow "Sign Out"
      And I am signed in as "sysadmin@hrtapp.com"
      And I follow "Users"
    Then I should see "01 Jan '11 21:30"


  Scenario: Adding malformed CSV file doesnt throw exception
    When I follow "Users"
    And I attach the file "spec/fixtures/malformed.csv" to "File"
    And I press "Upload and Import"
    Then I should see "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at"

  Scenario: Admin can upload users
    When I follow "Users"
    And I attach the file "spec/fixtures/users.csv" to "File"
    And I press "Upload and Import"
    Then I should see "Created 4 of 4 users successfully"
    And I should see "user1"
    And I should see "user2"
    And I should see "user3"
    And I should see "user4"


  Scenario: Admin can see error if no csv file is not attached for upload
    When I follow "Users"
    And I press "Upload and Import"
    Then I should see "Please select a file to upload"


  Scenario: Admin can see error when invalid csv file is attached for upload and download template
    When I follow "Users"
    And I attach the file "spec/fixtures/invalid.csv" to "File"
    And I press "Upload and Import"
    Then I should see "Wrong fields mapping. Please download the CSV template"
    When I follow "Download template"
    Then I should see "organization_name,email,full_name,roles,password,password_confirmation"

  Scenario Outline: An admin can filter users
    Given an organization exists with name: "organization2"
    And an user exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization
    And an organization exists with name: "organization3"
    And an user exists with email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization
    When I follow "Users"
    And I fill in "query" with "<first>"
    And I press "Search"
    Then I should see "Found 1 users matching <first>"
    And I should see "<first>"
    And I should not see "<second>"
    And I fill in "query" with "<second>"
    When I press "Search"
    Then I should see "Found 1 users matching <second>"
    And I should see "<second>"
    And I should not see "<first>"

    Examples:
       | first            | second           |
       | user1            | user2            |
       | user2            | user1            |
       | user1@hrtapp.com | user2@hrtapp.com |
       | user2@hrtapp.com | user1@hrtapp.com |
       | Full name 1      | Full name 2      |
       | Full name 2      | Full name 1      |
       | organization2    | organization3    |
       | organization3    | organization2    |


  Scenario Outline: An admin can sort users
    Given an organization exists with name: "organization2"
    And a reporter exists with email: "user1@hrtapp.com", full_name: "Full name 1", organization: the organization, current_sign_in_at: "2010-09-19 10:48:23"
    And an organization exists with name: "organization3"
    And an activity_manager exists with email: "user2@hrtapp.com", full_name: "Full name 2", organization: the organization, current_sign_in_at: "2011-09-19 10:48:23"
    When I follow "Users"
    # filter out admin user
    And I fill in "query" with "user"
    And I press "Search"
    And I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text1>"
    And column "<column>" row "2" should have text "<text2>"
    When I follow "<column_name>"
    Then column "<column>" row "1" should have text "<text2>"
    And column "<column>" row "2" should have text "<text1>"

      Examples:
        | column_name  | column | text1            | text2            |
        | Full Name    | 1      | Full name 1      | Full name 2      |
        | Email        | 2      | user2@hrtapp.com | user1@hrtapp.com |
        | Organization | 3      | organization2    | organization3    |
        | Last login   | 4      | 19 Sep '10 10:48 | 19 Sep '11 10:48 |


  Scenario: An admin can create Activity Manager and assign organizations for managing
    Given an organization exists with name: "organization2"
    And an user exists with organization: the organization
    And an organization exists with name: "organization3"
    And an user exists with organization: the organization
    When I follow "Users"
    And I follow "Create User"
    And I select "organization2" from "Organization"
    And I fill in "Email" with "pink.panter1@hrtapp.com"
    And I fill in "Full name" with "Pink Panter"
    And I select "Activity manager" from "Assign roles to this user"
    And I select "organization2" from "Assign organizations to this Activity Manager"
    And I select "organization3" from "Assign organizations to this Activity Manager"
    And I press "Create New User"
    Then I should see "User was successfully created"
    When I follow "Pink Panter"
    # Then the "Assign organizations to this Activity Manager" field should contain "organization2"
    # And the "Assign organizations to this Activity Manager" field should contain "organization3"
