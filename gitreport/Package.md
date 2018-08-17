Generates Git reports from Ballerina.

# Package Overview

The GitReport connector allows you to list all the pull requests you sent and list all the issues you created, commented, etc.

## Compatibility

| Ballerina Version  |
|:------------------:|
| 0.981.0            |

## Getting started

1. Refer the [Getting Started](https://ballerina.io/learn/getting-started/) guide to download and install Ballerina.

2. Get a personal access token from GitHUB account. The following guide will help you get obtain the token.

    [Creating a personal access token for the command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

3. Create a new Ballerina project by executing the following command at package root.

    ```shell
    $ ballerina init
    ```

4. Create a `ballerina.conf` file at package root and add the obtained token as follows.

   ```ballerina.conf
   GITHUB_TOKEN="your_personal_access_token"
   ```

4. Import the GitReport package to your Ballerina program as follows.

    ```ballerina
        import chanakal/gitreport;
    ```

## Sample code

This code explains how to get the pull requests sent to the given set of GitHub repositories by the given username after the given date.

```ballerina
import ballerina/config;
import ballerina/http;
import ballerina/io;
import chanakal/gitreport;

endpoint gitreport:Client gitReportClient {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString(GITHUB_TOKEN)
        }
    }
};

function main (string... args) {
    string githubUser = "ldclakmal";
    string[] githubRepoList = [
        "https://github.com/wso2/transport-http",
        "https://github.com/ballerina-platform/ballerina-lang"
    ];
    string scanFromDate = "2018-01-01";

    var details = gitReportClient->getPullRequestList(githubUser, githubRepoList, scanFromDate, gitreport:STATE_ALL);
    match details {
        () => {}
        error err => { io:println(err); }
    }
}
```
