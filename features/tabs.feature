Feature: As a User, I would like to be able to see my first tree and tabs

Background: A User logs in
  Given I have a tree with a tab
    When I visit "/sign_in"
    And I fill in "Email" with "user@example.com"
    And I fill in "Password" with "password"
    And I press "Submit"
    And I should see "Your Trees"
    Then I should see "Tree 1"
    And I should see "ReRoot"

  Scenario: I see my first tab
    And I should see "Tab 1"
    Then I should see "Tab 1"
    And I should see "Name"
    And I should see "Url"

  Scenario: I create a second tab
    And I fill in "Name" with "Tab 3"
    And I fill in "Url" with "www.google.com"
    And I press "Create Tab"
    Then I should see "Tab Created."
    Then I should see "Tab 3"
