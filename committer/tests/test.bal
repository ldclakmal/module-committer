import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/test;

endpoint Client committerReportClient {};

@test:Config
function testPrintPullRequestList() {
    string githubUser = "chanakal";
    var details = committerReportClient->printPullRequestList(githubUser, STATE_ALL);
    match details {
        () => {}
        error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
function testPrintIssueList() {
    string githubUser = "chanakal";
    var details = committerReportClient->printIssueList(githubUser, STATE_ALL);
    match details {
        () => {}
        error err => {
            test:assertFail(msg = err.message);
        }
    }
}

@test:Config
function testPrintEmailList() {
    string userEmail = "chanakal@abc.com";
    string[] excludeEmails = ["mygroup@abc.com"];
    var details = committerReportClient->printEmailList(userEmail, excludeEmails);
    match details {
        () => {}
        error err => {
            test:assertFail(msg = err.message);
        }
    }
}
