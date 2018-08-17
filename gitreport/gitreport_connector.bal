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

public type GitReportConnector object {

    public http:Client client;

    documentation {
        Prints the pull request URLs for the given status and given set of GitHub repositories
        P{{githubUser}} GitHub username
        P{{githubRepoList}} GitHub repository URL list
        P{{scanFromDate}} Starting date of the scan
        P{{status}} GitHub status (`gitreport:STATE_ALL`, `gitreport:STATE_OPEN`, `gitreport:STATE_CLOSED`)
        R{{}} If success, returns nill, else returns an `error`
    }
    public function getPullRequestList(string githubUser, string[] githubRepoList, string? scanFromDate, string status)
                        returns error?;
};

function GitReportConnector::getPullRequestList(string githubUser, string[] githubRepoList,
                                                string? scanFromDate, string status) returns error? {

    endpoint http:Client httpClient = self.client;

    int fromDate = -1;
    match scanFromDate {
        string date => fromDate = <int>time:parse(date, DATE_FORMAT).time;
        () => {}
    }

    int totalPrCount = 0;
    foreach githubRepoUrl in githubRepoList {
        string githubOrgWithRepo = githubRepoUrl.replace(GITHUB_URL, EMPTY_STRING).trim();
        string requestPath = REPOS + FORWARD_SLASH + githubOrgWithRepo + PULLS + QUESTION_MARK + status;

        io:println("---");
        io:println("Details of the GitHub parameters");
        io:println("    GitHub Org/Repo : " + githubOrgWithRepo);
        io:println("    GitHub User     : " + githubUser);
        io:println("    Scan From       : " + (scanFromDate but { () => EMPTY_STRING}));
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
                                // Check for the PR created date and stop the process if it is older than the given date
                                // since the PR scan starts from today, until the date of GitHub repo created.
                                if (fromDate == -1) {
                                    int createdDate = <int>time:parse(pr.created_at.toString()
                                        .split(TIME_BOUNDARY)[0], DATE_FORMAT).time;
                                    if (createdDate < fromDate) {
                                        isContinue = false;
                                        break;
                                    }
                                }

                                // Check for the PR is from the given user, if so add it into the list
                                if (pr.user.login.toString() == githubUser) {
                                    listOfPullRequests[prCount] = pr.html_url.toString();
                                    prCount++;
                                    totalPrCount++;
                                }
                            }
                        }
                        error e => {
                            log:printError("Error while converting json into json[]", err = e);
                            return e;
                        }
                    }

                }
                error e => {
                    log:printError("Error while calling the GitHub REST API", err = e);
                    return e;
                }
            }
        }
        io:println(" ✔");
        io:println("---");
        printList(listOfPullRequests);
    }
    io:println("---");
    io:println("Total PR Count: " + totalPrCount);
    io:println("---");
    return ();
}
