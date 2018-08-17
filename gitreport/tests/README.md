# Package GitReport - Tests

The GitReport connector allows you to list all the pull requests you sent and list all the issues you created, commented, etc.

## Compatibility

| Ballerina Version  |
|:------------------:|
| 0.981.0            |

## Running tests

In order to run the tests, you need to have a personal access token from GitHUB account. The following guide will help you get obtain the token.

[Creating a personal access token for the command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

Then, you need to create a `ballerina.conf` file at package root and add the obtained token as follows.

###### ballerina.conf

```ballerina.conf
GITHUB_TOKEN="your_personal_access_token"
```

#### Run all the test cases
Go to the root of the project and execute following commands.
```
ballerina init
ballerina test gitreport -c ballerina.conf
```
