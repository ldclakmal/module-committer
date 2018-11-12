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
