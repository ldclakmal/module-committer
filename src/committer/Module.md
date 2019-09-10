Generates WSO2 Committer Report from Ballerina.

# Module Overview

The committer connector generates the report for WSO2 Committer Request. It allows you to list all the pull requests you sent, list all the issues you get involved and list all the emails you get involved.

## Compatibility

| Ballerina Version  |
|:------------------:|
| 1.0                |

## Getting Started

### Setup GitHub account

- If you want to print GitHub report, you need to get credentials from GitHub. Please follow these setups.

    1. In your [GitHub profile settings](https://github.com/settings/profile), go to **Developer settings -> Personal access tokens**.
    2. Generate a new token to access the GitHub API.

### Setup GMail account

- Please follow these steps if and only if you want to print GMail report. Otherwise move to section [How to Run](##how-to-run).

    1. Get OAuth 2.0 credentials for your GMail account. The following guide will help you get obtain the token.

        [How to obtain Google OAuth2.0 Credentials](https://gist.github.com/ldclakmal/6c43ed7dfaa19d7eb0db324402d14102)

### Setup Credentials

- Once you obtained all the credentials, follow these steps.

    1. Create a new Ballerina project refering to the "Projects" secion of https://v1-0.ballerina.io/learn/how-to-structure-ballerina-code/.

    2. Create a `ballerina.conf` file at module root and add the obtained token as follows.

       ```ballerina.conf
       GMAIL_ACCESS_TOKEN="your_access_token"
       GMAIL_CLIENT_ID="your_client_id"
       GMAIL_CLIENT_SECRET="your_client_secret"
       GMAIL_REFRESH_TOKEN="your_refresh_token"
       GITHUB_TOKEN="your_github_personal_access_token"
       ```

## How to Run

1. Refer the [Getting Started](https://ballerina.io/learn/getting-started/) guide to download and install Ballerina.

2. Import the WSO2 Committer Report module to your Ballerina program as follows.

    ```ballerina
    import ldclakmal/committer;
    ```

3. Create an client endpoint as follows:

    ```ballerina
    committer:CommitterReportConfiguration committerReportConfig = {
        githubToken: config:getAsString("GITHUB_TOKEN"),
        gmailAccessToken: config:getAsString("ACCESS_TOKEN"),
        gmailClientId: config:getAsString("CLIENT_ID"),
        gmailClientSecret: config:getAsString("CLIENT_SECRET"),
        gmailRefreshToken: config:getAsString("REFRESH_TOKEN")
    };

    committer:Client committerReportClient = new(committerReportConfig);
    ```

4. Call the action that you need to print the report. Following **sample code** section will help you to implement the necessary report.

5. Run your program as follows.

    ```ballerina
    ballerina run your-program.bal --b7a.config.file=/path/to/conf/file
    ```

### Sample Code

This code explains how to get the given state pull requests sent by the given username.

```ballerina
import ballerina/io;
import ldclakmal/committer;

committer:CommitterReportConfiguration committerReportConfig = {
    githubToken: config:getAsString("GITHUB_TOKEN")
};

committer:Client committerReportClient = new(committerReportConfig);

public function main() {
    string githubUser = "ldclakmal";
    var response = committerReportClient->printPullRequestList(githubUser, committer:STATE_ALL);
    if (response is error) {
        io:println(response);
    }
}
```

This code explains how to get the given state issues, that the given username involves in.

```ballerina
import ballerina/io;
import ldclakmal/committer;

committer:CommitterReportConfiguration committerReportConfig = {
    githubToken: config:getAsString("GITHUB_TOKEN")
};

committer:Client committerReportClient = new(committerReportConfig);

public function main() {
    string githubUser = "ldclakmal";
    var response = committerReportClient->printIssueList(githubUser, committer:STATE_ALL);
    if (response is error) {
        io:println(response);
    }
}
```

This code explains how to get the emails, that the given user involves in. This prints under two categories as 'Initiated Emails' and 'Contributed Emails'

```ballerina
import ballerina/io;
import ldclakmal/committer;

committer:CommitterReportConfiguration committerReportConfig = {
    gmailAccessToken: config:getAsString("GMAIL_ACCESS_TOKEN"),
    gmailClientId: config:getAsString("GMAIL_CLIENT_ID"),
    gmailClientSecret: config:getAsString("GMAIL_CLIENT_SECRET"),
    gmailRefreshToken: config:getAsString("GMAIL_REFRESH_TOKEN")
};

committer:Client committerReportClient = new(committerReportConfig);

public function main() {
    string userEmail = "ldclakmal@gmail.com";
    string[] excludeEmails = ["mygroup@abc.com"];
    var response = committerReportClient->printEmailList(userEmail, excludeEmails);
    if (response is error) {
        io:println(response);
    }
}
```

### Sample Program

- Please refer following URL for the full implementation.
https://github.com/ldclakmal/ballerina-samples/blob/master/connectors/committer.bal

- Run this program as follows:

    ```ballerina
    ballerina run committer.bal --b7a.config.file=sample-users.toml
    ```
