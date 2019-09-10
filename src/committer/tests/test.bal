import ballerina/config;
import ballerina/test;

CommitterReportConfiguration committerReportConfig = {
    githubToken: config:getAsString("GITHUB_TOKEN"),
    gmailAccessToken: config:getAsString("GMAIL_ACCESS_TOKEN"),
    gmailClientId: config:getAsString("GMAIL_CLIENT_ID"),
    gmailClientSecret: config:getAsString("GMAIL_CLIENT_SECRET"),
    gmailRefreshToken: config:getAsString("GMAIL_REFRESH_TOKEN")
};

Client committerReportClient = new(committerReportConfig);

string githubUser = config:getAsString("GITHUB_USER");

@test:Config{}
function testPrintPullRequestList() {
    var response = committerReportClient->printPullRequestList(githubUser, STATE_ALL);
    if (response is error) {
        test:assertFail(msg = response.detail()?.message.toString());
    }
}

@test:Config{}
function testPrintIssueList() {
    var response = committerReportClient->printIssueList(githubUser, STATE_ALL);
    if (response is error) {
        test:assertFail(msg = response.detail()?.message.toString());
    }
}

@test:Config{}
function testPrintEmailList() {
    string userEmail = "b7a.demo@gmail.com";
    string[] excludeEmails = ["mygroup@abc.com"];
    var response = committerReportClient->printEmailList(userEmail, excludeEmails);
    if (response is error) {
        test:assertFail(msg = response.detail()?.message.toString());
    }
}
