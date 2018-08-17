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

import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/test;

endpoint Client gitReportClient {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString(GITHUB_TOKEN)
        }
    },
    githubOrg: config:getAsString(GITHUB_ORGANIZATION_NAME),
    githubRepo: config:getAsString(GITHUB_REPOSITORY_NAME),
    githubUser: config:getAsString(GITHUB_USERNAME),
    scanFromDate: config:getAsString(SCAN_FROM_DATE)
};

@test:Config
function testGetPullRequestList() {
    var details = gitReportClient->getPullRequestList(STATE_ALL);
    match details {
        string[] prList => {
            foreach pr in prList {
                io:println(pr);
            }
        }
        error err => {
            test:assertFail(msg = err.message);
        }
    }
}
