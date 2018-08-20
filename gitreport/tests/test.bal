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
    }
};

@test:Config
function testGetPullRequestList() {
    string githubUser = "ldclakmal";
    string[] githubRepoList = [
        "https://github.com/wso2/transport-http",
        "https://github.com/ballerina-platform/ballerina-lang",
        "https://github.com/ballerina-platform/ballerina-examples",
        "https://github.com/ballerina-platform/ballerina-www",
        "https://github.com/wso2-ballerina/package-twitter",
        "https://github.com/wso2-ballerina/package-gmail",
        "https://github.com/wso2-ballerina/package-salesforce",
        "https://github.com/wso2-ballerina/package-googlespreadsheet",
        "https://github.com/wso2-ballerina/package-twilio",
        "https://github.com/wso2-ballerina/package-soap",
        "https://github.com/wso2-ballerina/package-github",
        "https://github.com/wso2-ballerina/package-scim2",
        "https://github.com/wso2-ballerina/package-jira",
        "https://github.com/wso2-ballerina/package-consul",
        "https://github.com/wso2-ballerina/package-sonarqube",
        "https://github.com/wso2-ballerina/package-kafka",
        "https://github.com/ballerina-guides/ballerina-demo",
        "https://github.com/ballerina-guides/ballerina-with-istio",
        "https://github.com/ballerina-guides/salesforce-twilio-integration",
        "https://github.com/ballerina-guides/sonarqube-github-integration",
        "https://github.com/ballerina-guides/gmail-spreadsheet-integration",
        "https://github.com/ballerina-guides/securing-restful-services-with-basic-auth"
    ];
    string scanFromDate = "2018-01-01";

    var details = gitReportClient->getPullRequestList(githubUser, githubRepoList, scanFromDate, STATE_ALL);
    match details {
        () => {}
        error err => {
            test:assertFail(msg = err.message);
        }
    }
}
