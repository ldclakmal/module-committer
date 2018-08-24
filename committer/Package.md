Generates WSO2 Committer Report from Ballerina.

# Package Overview

The WSO2 Committer Report connector allows you to list all the pull requests you sent, list all the issues you get involved and list all the emails you get involved.

## Compatibility

| Ballerina Version  |
|:------------------:|
| 0.981.1            |

## Getting started

1. Refer the [Getting Started](https://ballerina.io/learn/getting-started/) guide to download and install Ballerina.

2. Get OAuth 2.0 credentials for your GMail account. The following guide will help you get obtain the token. This is needed if and only if you are printing the email report.

    [How to obtain Google OAuth2.0 Credentials](https://gist.github.com/ldclakmal/6c43ed7dfaa19d7eb0db324402d14102)

3. Create a new Ballerina project by executing the following command at package root.

    ```shell
    $ ballerina init
    ```

4. Create a `ballerina.conf` file at package root and add the obtained token as follows.

   ```ballerina.conf
   ACCESS_TOKEN="your_access_token"
   CLIENT_ID="your_client_id"
   CLIENT_SECRET="your_client_secret"
   REFRESH_TOKEN="your_refresh_token"
   ```

5. Import the WSO2 Committer Report package to your Ballerina program as follows.

    ```ballerina
    import chanakal/committer;
    ```

## Sample code

This code explains how to get the given state pull requests sent by the given username.

```ballerina
import ballerina/io;
import chanakal/committer;

endpoint committer:Client committerReportClient {};

function main (string... args) {
    string githubUser = "ldclakmal";
    var details = committerReportClient->printPullRequestList(githubUser, committer:STATE_ALL);
    match details {
        () => {}
        error err => { io:println(err); }
    }
}
```

This code explains how to get the given state issues, that the given username involves in.

```ballerina
import ballerina/io;
import chanakal/committer;

endpoint committer:Client committerReportClient {};

function main (string... args) {
    string githubUser = "ldclakmal";
    var details = committerReportClient->printIssueList(githubUser, committer:STATE_ALL);
    match details {
        () => {}
        error err => { io:println(err); }
    }
}
```

This code explains how to get the emails, that the given user involves in.

```ballerina
import ballerina/io;
import chanakal/committer;

endpoint committer:Client committerReportClient {};

function main (string... args) {
    string email = "chanakal@wso2.com";
    string[] excludeEmails = ["vacation-group@wso2.com"];
    int maxListSize = 150;
    var details = committerReportClient->printEmailList(email, 150, excludeEmails);
    match details {
        () => {}
        error err => {
            test:assertFail(msg = err.message);
        }
    }
}
```
