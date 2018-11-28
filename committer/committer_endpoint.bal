import ballerina/http;

# Object for CommitterReport endpoint.
#
# + committerReportConnector - Reference to `CommitterReportConnector` type
public type Client client object {

    public CommitterReportConnector committerReportConnector;

    public function __init(CommitterReportConfiguration? config = ()) {
        self.committerReportConnector = new(GITHUB_API_BASE_URL, config);
    }

    # Prints the pull request URLs of given state, that the given user created
    #
    # + githubUser - GitHub username
    # + state - GitHub state (`committer:STATE_ALL`, `committer:STATE_OPEN`, `committer:STATE_CLOSED`)
    # + return - If success, returns nill, else returns an `error`
    public remote function printPullRequestList(string githubUser, string state) returns error? {
        return self.committerReportConnector->printPullRequestList(githubUser, state);
    }

    # Prints the issue URLs of given state, that the given user involves in
    #
    # + githubUser - GitHub username
    # + state - GitHub state (`committer:STATE_ALL`, `committer:STATE_OPEN`, `committer:STATE_CLOSED`)
    # + return - If success, returns nill, else returns an `error`
    public remote function printIssueList(string githubUser, string state) returns error? {
        return self.committerReportConnector->printIssueList(githubUser, state);
    }

    # Prints the emails excluding the given given emails, that the given user involves in
    #
    # + userEmail - User email address
    # + excludeEmails - List of emails that need to be excluded from 'to' list
    # + return - If success, returns nill, else returns an `error`
    public remote function printEmailList(string userEmail, string[]? excludeEmails) returns error? {
        return self.committerReportConnector->printEmailList(userEmail, excludeEmails);
    }
};

# Object for committer report configuration.
#
# + clientConfig - The http client endpoint configuration
public type CommitterReportConfiguration record {
    http:ClientEndpointConfig clientConfig;
};
