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

@final string GIT_USERNAME = "ldclakmal";
@final string NEXT_REALTION = "rel=\"next\"";
@final string LAST_RELATION = "rel=\"last\"";
@final string EMPTY_STRING = "";
@final string SEMICOLON = ";";
@final string COMMA = ",";

endpoint http:Client githubClient {
    url: "https://api.github.com",
    auth: {
        scheme: http:OAUTH2,
        accessToken: config:getAsString("GITHUB_TOKEN")
    }
};

function main(string... args) {
    boolean isContinue = true;
    string path = "/repos/ballerina-platform/ballerina-lang/pulls?state=all";
    while (isContinue) {
        var response = githubClient->get(path);
        match response {
            http:Response res => {
                if (res.hasHeader("Link")) {
                    string link = res.getHeader("Link");
                    //io:println("Link Headers: " + link);
                    string[] urlWithRelationArray = link.split(COMMA);
                    string nextUrl;
                    string lastUrl;
                    foreach urlWithRealtion in urlWithRelationArray {
                        string urlWithBrackets = urlWithRealtion.split(SEMICOLON)[0].trim();
                        if (urlWithRealtion.contains(NEXT_REALTION)) {
                            nextUrl = urlWithBrackets.substring(1, urlWithBrackets.length() - 1)
                            .replace(githubClient.config.url, EMPTY_STRING);
                        } else if (urlWithRealtion.contains(LAST_RELATION)) {
                            lastUrl = urlWithBrackets.substring(1, urlWithBrackets.length() - 1)
                            .replace(githubClient.config.url, EMPTY_STRING);
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
                    if (pr.user.login.toString() == GIT_USERNAME) {
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
