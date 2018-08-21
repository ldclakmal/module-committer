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
import ballerina/time;

int totalCount = 0;

public type GitReportConnector object {

    public http:Client client;

    //documentation {
    //    Prints the pull request URLs for the given status and given set of GitHub repositories
    //    P{{githubUser}} GitHub username
    //    P{{githubRepoList}} GitHub repository URL list
    //    P{{scanFromDate}} Starting date of the scan. It should be in `YYYY-MM-DD` format
    //    P{{status}} GitHub status (`gitreport:STATE_ALL`, `gitreport:STATE_OPEN`, `gitreport:STATE_CLOSED`)
    //    R{{}} If success, returns nill, else returns an `error`
    //}
    public function getPullRequestList(string githubUser, string state) returns error?;
};

function GitReportConnector::getPullRequestList(string githubUser, string state) returns error? {

    string requestPath = SEARCH_API + TYPE_PR + PLUS + AUTHOR + githubUser + PLUS + state;
    map<string[]> responseMap;

    var r = doSomething(self.client, requestPath, responseMap);
    match r {
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

function doSomething(http:Client client, string requestPath, map<string[]> responseMap) returns error? {
    endpoint http:Client httpClient = client;
    var response = httpClient->get(requestPath);
    match response {
        http:Response res => {
            json payload = check res.getJsonPayload();
            totalCount = untaint check <int>payload.total_count;
            json[] prList = check <json[]>payload.items;
            foreach pr in prList {
                string repoUrl = check <string>pr.repository_url;
                string prUrl = check <string>pr.html_url;
                addToMap(responseMap, repoUrl, prUrl);
            }

            if (res.hasHeader(LINK_HEADER)) {
                string linkHeader = res.getHeader(LINK_HEADER);
                string nextResourcePath = getNextResourcePath(linkHeader);
                // Check for the next page of PR is exists.
                if (nextResourcePath != EMPTY_STRING) {
                    return doSomething(client, nextResourcePath, responseMap);
                }
            }
            return ();
        }
        error e => {
            return e;
        }
    }
}
