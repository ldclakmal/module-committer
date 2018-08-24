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

import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import wso2/gmail;

int totalCount = 0;

public type CommitterReportConnector object {

    public http:Client client;

    documentation {
        Prints the pull request URLs of given state, that the given user created

        P{{githubUser}} GitHub username
        P{{state}} GitHub state (`committer:STATE_ALL`, `committer:STATE_OPEN`, `committer:STATE_CLOSED`)
        R{{}} If success, returns nill, else returns an `error`
    }
    public function printPullRequestList(string githubUser, string state) returns error?;

    documentation {
        Prints the issue URLs of given state, that the given user involves in

        P{{githubUser}} GitHub username
        P{{state}} GitHub state (`committer:STATE_ALL`, `committer:STATE_OPEN`, `committer:STATE_CLOSED`)
        R{{}} If success, returns nill, else returns an `error`
    }
    public function printIssueList(string githubUser, string state) returns error?;

    documentation {
        Prints the emails excluding the given given emails, that the given user involves in

        P{{userEmail}} User email address
        P{{maxListSize}} Maximum size of the email list. This can be any large integer value
        P{{excludeEmails}} List of emails that need to be excluded from 'to' list
        R{{}} If success, returns nill, else returns an `error`
    }
    public function printEmailList(string userEmail, int maxListSize, string[]? excludeEmails) returns error?;
};

// API Doc: https://developer.github.com/v3/search/#search-issues
function CommitterReportConnector::printPullRequestList(string githubUser, string state) returns error? {

    log:printInfo("Preparing GitHub pull request report for user:" + githubUser + " & " + state);

    map<string[]> responseMap;
    string requestPath = SEARCH_API + TYPE_PR + PLUS + AUTHOR + githubUser + PLUS + state;
    var response = prepareMapForGitHUb(self.client, requestPath, responseMap);
    match response {
        () => {
            io:println("---");
            io:println("Report of the GitHub Pull Requests");
            io:println("• GitHub User   : " + githubUser);
            io:println("• State         : " + state);
            io:println("• Total PR Count: " + totalCount);
            io:println("---");
            printMap(responseMap);
            return ();
        }
        error e => {
            log:printError("Error while calling the GitHub REST API", err = e);
            return e;
        }
    }
}

// API Doc: https://developer.github.com/v3/search/#search-issues
function CommitterReportConnector::printIssueList(string githubUser, string state) returns error? {

    log:printInfo("Preparing GitHub issue report for user:" + githubUser + " & " + state);

    map<string[]> responseMap;
    string requestPath = SEARCH_API + TYPE_ISSUE + PLUS + INVOLVES + githubUser + PLUS + state;
    var response = prepareMapForGitHUb(self.client, requestPath, responseMap);
    match response {
        () => {
            io:println("---");
            io:println("Report of the GitHub Issues");
            io:println("• GitHub User       : " + githubUser);
            io:println("• State             : " + state);
            io:println("• Total Issue Count : " + totalCount);
            io:println("---");
            printMap(responseMap);
            return ();
        }
        error e => {
            log:printError("Error while calling the GitHub REST API", err = e);
            return e;
        }
    }
}

function CommitterReportConnector::printEmailList(string userEmail, int maxListSize, string[]? excludeEmails) returns error? {
    endpoint gmail:Client gmailEP {
        clientConfig: {
            auth: {
                accessToken: config:getAsString("ACCESS_TOKEN"),
                clientId: config:getAsString("CLIENT_ID"),
                clientSecret: config:getAsString("CLIENT_SECRET"),
                refreshToken: config:getAsString("REFRESH_TOKEN")
            }
        }
    };

    log:printInfo("Preparing EMail report for user:" + userEmail);

    string queryParams = buildQueryParams(userEmail, excludeEmails);
    gmail:MsgSearchFilter searchFilter = { includeSpamTrash: false, maxResults: <string>maxListSize, q:queryParams };
    var threadList = gmailEP->listThreads(ME, filter = searchFilter);
    match threadList {
        gmail:ThreadListPage list => {
            io:println("---");
            io:println("Report of the EMails");
            io:println("• EMail User        : " + userEmail);
            io:println("• Search Filter     : " + queryParams);
            io:println("• Total Email Count : " + list.resultSizeEstimate);
            io:println("---");
            foreach i, thread in list.threads {
                var threadInfo = gmailEP->readThread(ME, <string>thread.threadId, format = gmail:FORMAT_METADATA,
                    metadataHeaders = [SUBJECT]);
                match threadInfo {
                    gmail:Thread t => {
                        string subject = <string>t.messages[0].headerSubject;
                        if (subject == EMPTY_STRING) {
                            subject = NO_SUBJECT;
                        }
                        io:println(subject);
                    }
                    gmail:GmailError e => return e;
                }
            }
            io:println("---");
            return ();
        }
        gmail:GmailError e => return e;
    }
}

// Prepare map by recursively calling the GitHub search API
function prepareMapForGitHUb(http:Client client, string requestPath, map<string[]> responseMap) returns error? {
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
                    return prepareMapForGitHUb(client, nextResourcePath, responseMap);
                }
            }
            return ();
        }
        error e => return e;
    }
}
