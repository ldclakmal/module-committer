# Package GitReport

The GitReport connector allows you to list all the pull requests you sent and list all the issues you created, commented, etc.

## Compatibility

| Ballerina Version  |
|:------------------:|
| 0.981.0            |

## Getting started

1. Refer the [Getting Started](https://ballerina.io/learn/getting-started/) guide to download and install Ballerina.

2. Import the GitReport package to your Ballerina program as follows.

    ```ballerina
    import chanakal/gitreport;
    ```

## Sample code

This code explains how to get the given state pull requests sent by the given username.

```ballerina
import ballerina/http;
import ballerina/io;
import chanakal/gitreport;

endpoint gitreport:Client gitReportClient {};

function main (string... args) {
    string githubUser = "ldclakmal";
    var details = gitReportClient->getPullRequestList(githubUser, gitreport:STATE_ALL);
    match details {
        () => {}
        error err => { io:println(err); }
    }
}
```
