import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/test;

CommitterReportConfiguration committerReportConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("ACCESS_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};

Client committerReportClient = new(config = committerReportConfig);

@test:Config
function testPrintPullRequestList() {
    string githubUser = "chanakal";
    var response = committerReportClient->printPullRequestList(githubUser, STATE_ALL);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config
function testPrintIssueList() {
    string githubUser = "chanakal";
    var response = committerReportClient->printIssueList(githubUser, STATE_ALL);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config
function testPrintEmailList() {
    string userEmail = "chanakal@abc.com";
    string[] excludeEmails = ["mygroup@abc.com"];
    var response = committerReportClient->printEmailList(userEmail, excludeEmails);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    }
}
