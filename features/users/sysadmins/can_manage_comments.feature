Feature: Reporter can see comments
  In order to help reporters see missed areas
  As a reporter
  I want to be able to see comments that reviewers have made

  Background:
    Given a basic reporter setup
      And a admin exists with email: "sysadmin@hrtapp.com", organization: the organization
      And a project exists with name: "project1", data_response: the data_response
      And an activity exists with name: "activity1", project: the project, data_response: the data_response
      And I am signed in as "sysadmin@hrtapp.com"

    Scenario: Sysadmin can see all comments on dashbaord
      Given a comment exists with comment: "comment1", commentable: the project, user: the reporter
        And a organization exists with name: "USAID"
        And a reporter exists with email: "reporter2@hrtapp.com", organization: the organization
        And a data_response should exist with data_request: the data_request, organization: the organization
        And a project exists with name: "Other Project", data_response: the data_response
        And a comment exists with comment: "comment2", commentable: the project, user: the reporter
      When I follow "Home"
      Then I should see "comment1"
        And I should see "comment2"

    @javascript
    Scenario: Sysadmin can manage comments on a response
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I fill in "Add Comment" with "response_comment"
        And I press "Comment"
      Then I should see "response_comment"
      When I follow "Edit" within ".comments_list"
        And I fill in "Edit Comment" with "edited_response_comment"
        And I press "Save" within ".comments_list"
      Then I should see "edited_response_comment"
      When I follow "Remove" within ".comments_list"
      Then I should see "This comment has been removed by sysadmin."
        And I should not see "edited_response_comment"

    @javascript
    Scenario: Reporter can comment on a project
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I follow "Projects"
        And I follow "project1"
        And I fill in "Add Comment" with "project_comment"
        And I press "Comment"
      Then I should see "project_comment"
      When I follow "Edit" within ".comments_list"
        And I fill in "Edit Comment" with "edited_project_comment"
        And I press "Save" within ".comments_list"
      Then I should see "edited_project_comment"
      When I follow "Remove" within ".comments_list"
      Then I should see "This comment has been removed by sysadmin."
        And I should not see "edited_project_comment"

    @javascript
    Scenario: Reporter can comment on an activity
      When I follow "Responses"
        And I follow "organization2: data_request1"
        And I follow "Projects"
        And I follow "activity1"
        And I fill in "Add Comment" with "activity_comment"
        And I press "Comment"
      Then I should see "activity_comment"
      When I follow "Edit" within ".comments_list"
        And I fill in "Edit Comment" with "edited_activity_comment"
        And I press "Save" within ".comments_list"
      Then I should see "edited_activity_comment"
      When I follow "Remove" within ".comments_list"
      Then I should see "This comment has been removed by sysadmin."
        And I should not see "edited_activity_comment"

    # @javascript
    # Scenario: Does not email users when a comment is made by a reporter
    #   Given no emails have been sent
    #   When I follow "Projects"
    #     And I follow "activity1"
    #     And I fill in "Add Comment" with "project_comment"
    #     And I press "Comment"
    #   Then "reporter@hrtapp.com" should not receive an email
