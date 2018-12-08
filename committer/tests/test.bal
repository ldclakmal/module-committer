import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/test;

CommitterReportConfiguration committerReportConfig = {
    githubToken: config:getAsString("GITHUB_TOKEN"),
    gmailAccessToken: config:getAsString("GMAIL_ACCESS_TOKEN"),
    gmailClientId: config:getAsString("GMAIL_CLIENT_ID"),
    gmailClientSecret: config:getAsString("GMAIL_CLIENT_SECRET"),
    gmailRefreshToken: config:getAsString("GMAIL_REFRESH_TOKEN")
};

Client committerReportClient = new(committerReportConfig);

@test:Config
function testPrintPullRequestList() {
    string githubUser = "ldclakmal";
    var response = committerReportClient->printPullRequestList(githubUser, STATE_ALL);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config
function testPrintIssueList() {
    string githubUser = "ldclakmal";
    var response = committerReportClient->printIssueList(githubUser, STATE_ALL);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config
function testPrintEmailList() {
    string userEmail = "ldclakmal@gmail.com";
    string[] excludeEmails = ["mygroup@abc.com"];
    var response = committerReportClient->printEmailList(userEmail, excludeEmails);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    }
}
