// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.package sample;

import ballerina/http;
import ballerina/io;
import ballerina/log;

int totalCount = 0;

public type GitReportConnector object {

    public http:Client client;

    documentation {
        Prints the pull request URLs of given state, that the given user created
        P{{githubUser}} GitHub username
        P{{state}} GitHub state (`gitreport:STATE_ALL`, `gitreport:STATE_OPEN`, `gitreport:STATE_CLOSED`)
        R{{}} If success, returns nill, else returns an `error`
    }
    public function printPullRequestList(string githubUser, string state) returns error?;

    documentation {
        Prints the issue URLs of given state, that the given user involves in
        P{{githubUser}} GitHub username
        P{{state}} GitHub state (`gitreport:STATE_ALL`, `gitreport:STATE_OPEN`, `gitreport:STATE_CLOSED`)
        R{{}} If success, returns nill, else returns an `error`
    }
    public function printIssueList(string githubUser, string state) returns error?;
};

// API Doc: https://developer.github.com/v3/search/#search-issues
function GitReportConnector::printPullRequestList(string githubUser, string state) returns error? {

    log:printInfo("Preparing GitHub pull request report for user:" + githubUser + " & " + state);

    map<string[]> responseMap;
    string requestPath = SEARCH_API + TYPE_PR + PLUS + AUTHOR + githubUser + PLUS + state;
    var response = prepareMap(self.client, requestPath, responseMap);
    match response {
        () => {
            io:println("---");
            io:println("Report of the GitHub Pull Requests");
            io:println("• GitHub User   : " + githubUser);
            io:println("• State         : " + state);
            io:println("• Total PR Count: " + totalCount);
            io:println("---");
            printReport(responseMap);
            return ();
        }
        error e => {
            log:printError("Error while calling the GitHub REST API", err = e);
            return e;
        }
    }
}

// API Doc: https://developer.github.com/v3/search/#search-issues
function GitReportConnector::printIssueList(string githubUser, string state) returns error? {

    log:printInfo("Preparing GitHub issue report for user:" + githubUser + " & " + state);

    map<string[]> responseMap;
    string requestPath = SEARCH_API + TYPE_ISSUE + PLUS + INVOLVES + githubUser + PLUS + state;
    var response = prepareMap(self.client, requestPath, responseMap);
    match response {
        () => {
            io:println("---");
            io:println("Report of the GitHub Issues");
            io:println("• GitHub User       : " + githubUser);
            io:println("• State             : " + state);
            io:println("• Total Issue Count : " + totalCount);
            io:println("---");
            printReport(responseMap);
            return ();
        }
        error e => {
            log:printError("Error while calling the GitHub REST API", err = e);
            return e;
        }
    }
}

// Prepare map by recursively calling the GitHub search API
function prepareMap(http:Client client, string requestPath, map<string[]> responseMap) returns error? {
    endpoint http:Client httpClient = client;
    var response = httpClient->get(requestPath);
    match response {
        http:Response res => {
            json payload = check res.getJsonPayload();
            totalCount = untaint check <int>payload.total_count;
            json[] itemList = check <json[]>payload.items;
            foreach item in itemList {
                string repoUrl = check <string>item.repository_url;
                string htmlUrl = check <string>item.html_url;
                addToMap(responseMap, repoUrl, htmlUrl);
            }

            if (res.hasHeader(LINK_HEADER)) {
                string linkHeader = res.getHeader(LINK_HEADER);
                string nextResourcePath = getNextResourcePath(linkHeader);
                // Check for the next page exists.
                if (nextResourcePath != EMPTY_STRING) {
                    return prepareMap(client, nextResourcePath, responseMap);
                }
            }
            return ();
        }
        error e => return e;
    }
}
