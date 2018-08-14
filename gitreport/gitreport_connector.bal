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
// under the License.
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

endpoint http:Client gitReportClient {
    url: API_URL,
    auth: {
        scheme: http:OAUTH2,
        accessToken: config:getAsString(GITHUB_TOKEN)
    }
};

function main(string... args) {
    string githubOrg = config:getAsString(GITHUB_ORGANIZATION_NAME);
    string githubRepo = config:getAsString(GITHUB_REPOSITORY_NAME);
    string githubUser = config:getAsString(GITHUB_USERNAME);

    boolean isContinue = true;
    string path = "/repos/" + githubOrg + "/" + githubRepo + "/pulls?state=all";
    while (isContinue) {
        var response = gitReportClient->get(path);
        match response {
            http:Response res => {
                if (res.hasHeader(LINK_HEADER)) {
                    string link = res.getHeader(LINK_HEADER);
                    //io:println("Link Headers: " + link);
                    string[] urlWithRelationArray = link.split(COMMA);
                    string nextUrl;
                    string lastUrl;
                    foreach urlWithRealtion in urlWithRelationArray {
                        string urlWithBrackets = urlWithRealtion.split(SEMICOLON)[0].trim();
                        if (urlWithRealtion.contains(NEXT_REALTION)) {
                            nextUrl = urlWithBrackets.substring(1, urlWithBrackets.length() - 1)
                            .replace(gitReportClient.config.url, EMPTY_STRING);
                        } else if (urlWithRealtion.contains(LAST_RELATION)) {
                            lastUrl = urlWithBrackets.substring(1, urlWithBrackets.length() - 1)
                            .replace(gitReportClient.config.url, EMPTY_STRING);
                        }
                    }
                    //io:println("Next URL: " + nextUrl);
                    //io:println("Last URL: " + lastUrl);

                    if (nextUrl.equalsIgnoreCase(lastUrl)) {
                        isContinue = false;
                    } else {
                        path = nextUrl;
                    }
                } else {
                    isContinue = false;
                }
                json[] payload = check <json[]>(check res.getJsonPayload());
                foreach i, pr in payload  {
                    if (pr.user.login.toString() == githubUser) {
                        io:println(pr.title);
                    }
                }
            }
            error err => {
                io:println(err);
            }
        }
    }
}
