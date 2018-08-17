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

public type GitReportConnector object {

    public string githubOrg;
    public string githubRepo;
    public string githubUser;
    public http:Client client;

    documentation {
        Return pull requests url list for the given status
        P{{status}} GitHub status (`gitreport:STATE_ALL`, `gitreport:STATE_OPEN`, `gitreport:STATE_CLOSED`)
        R{{}} If success, returns string array with URLs of pull requests,e lse returns an `error`
    }
    public function getPullRequestList(string status) returns (string[]|error);
};

function GitReportConnector::getPullRequestList(string status) returns (string[]|error) {
    endpoint http:Client httpClient = self.client;
    string requestPath = REPOS + FORWARD_SLASH + self.githubOrg + FORWARD_SLASH + self.githubRepo + PULLS + "?" + status;
    io:println("---");
    io:println("Details of the GitHub parameters");
    io:println("    GitHub Org    : " + self.githubOrg);
    io:println("    GitHub Repo   : " + self.githubRepo);
    io:println("    GitHub User   : " + self.githubUser);
    io:println("---");
    io:print("Processing ");
    string[] listOfPullRequests;
    boolean isContinue = true;
    int prCount = 0;
    while (isContinue) {
        io:print("•");
        var response = httpClient->get(requestPath);
        match response {
            http:Response res => {
                if (res.hasHeader(LINK_HEADER)) {
                    string linkHeader = res.getHeader(LINK_HEADER);
                    string nextUrl;
                    string lastUrl;
                    (nextUrl, lastUrl) = getNextAndLastResourcePaths(linkHeader);
                    // Check for the last page of PRs and if so, stop the loop.
                    if (nextUrl.equalsIgnoreCase(lastUrl)) {
                        isContinue = false;
                    } else {
                        requestPath = nextUrl;
                    }
                } else {
                    isContinue = false;
                }
                var resPayload = <json[]>(check res.getJsonPayload());
                match resPayload {
                    json[] payload => {
                        foreach pr in payload  {
                            if (pr.user.login.toString() == self.githubUser) {
                                listOfPullRequests[prCount] = pr.html_url.toString();
                                prCount++;
                            }
                        }
                    }
                    error e => {
                        log:printError("Error while converting json into json[]", err = e);
                    }
                }

            }
            error e => {
                log:printError("Error while calling the GitHub REST API", err = e);
            }
        }
    }
    io:println(" ✔");
    io:println("---");
    return listOfPullRequests;
}
