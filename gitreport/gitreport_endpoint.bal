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

import ballerina/http;

documentation {
    Object for GitReport endpoint.
    F{{gitReportConfig}} Reference to `GitReportConfiguration` type
    F{{gitReportConnector}} Reference to `GitReportConnector` type
}
public type Client object {

    public GitReportConfiguration gitReportConfig;
    public GitReportConnector gitReportConnector = new;

    documentation {
        Initialize GitReport endpoint.
        P{{config}} GitReport configuraion
    }
    public function init(GitReportConfiguration config);

    documentation {
        Returns GitReport connector.
        R{{}} GitReport connector object
    }
    public function getCallerActions() returns GitReportConnector;

};

documentation {
    F{{githubOrg}} GitHub organization name
    F{{githubRepo}} GitHub repository name
    F{{githubUser}} GitHub username
    F{{scanFromDate}} Starting date of the scan
    F{{clientConfig}} The http client endpoint configuration
}
public type GitReportConfiguration record {
    string githubOrg;
    string githubRepo;
    string githubUser;
    string scanFromDate;
    http:ClientEndpointConfig clientConfig;
};

function Client::init(GitReportConfiguration config) {
    config.clientConfig.url = API_URL;
    self.gitReportConnector.githubOrg = config.githubOrg;
    self.gitReportConnector.githubRepo = config.githubRepo;
    self.gitReportConnector.githubUser = config.githubUser;
    self.gitReportConnector.scanFromDate = config.scanFromDate;
    self.gitReportConnector.client.init(config.clientConfig);
}

function Client::getCallerActions() returns GitReportConnector {
    return self.gitReportConnector;
}
