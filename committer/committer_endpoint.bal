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

# Object for CommitterReport endpoint.
#
# + committerReportConfig - Reference to `CommitterReportConfiguration` type
# + committerReportConnector - Reference to `CommitterReportConnector` type
public type Client object {

    public CommitterReportConfiguration committerReportConfig;
    public CommitterReportConnector committerReportConnector = new;


    # Initialize CommitterReport endpoint.
    #
    # + config - CommitterReport configuraion
    public function init(CommitterReportConfiguration config);

    # Returns CommitterReport connector.
    #
    # + return - CommitterReport connector object
    public function getCallerActions() returns CommitterReportConnector;
};

# Object for committer report configuration.
#
# + clientConfig - The http client endpoint configuration
public type CommitterReportConfiguration record {
    http:ClientEndpointConfig clientConfig;
};

function Client::init(CommitterReportConfiguration config) {
    config.clientConfig.url = API_BASE_URL;
    self.committerReportConnector.client.init(config.clientConfig);
}

function Client::getCallerActions() returns CommitterReportConnector {
    return self.committerReportConnector;
}
