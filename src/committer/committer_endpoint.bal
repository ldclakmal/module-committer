import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/stringutils;
import wso2/gmail;

# Object for CommitterReport endpoint.
#
# + gitHubToken - GitHub token
# + gitHubClient - Reference to HTTP client endpoint for GitHub API
# + gmailClient - Reference to HTTP client endpoint for GMail API
public type Client client object {

    string gitHubToken;
    int totalCount = 0;
    http:Client gitHubClient;
    gmail:Client gmailClient;

    public function __init(CommitterReportConfiguration config) {
        self.gitHubClient = new(GITHUB_API_BASE_URL);
        self.gitHubToken = config.githubToken;

        gmail:GmailConfiguration gmailConfig = {
            oauthClientConfig: {
                accessToken: config.gmailAccessToken,
                refreshConfig: {
                    clientId: config.gmailClientId,
                    clientSecret: config.gmailClientSecret,
                    refreshToken: config.gmailRefreshToken,
                    refreshUrl: gmail:REFRESH_URL
                }
            }
        };
        self.gmailClient = new(gmailConfig);
    }

    # Prints the pull request URLs of given state, that the given user created.
    # API Doc: https://developer.github.com/v3/search/#search-issues
    #
    # + githubUser - GitHub username
    # + state - GitHub state (`committer:STATE_ALL`, `committer:STATE_OPEN`, `committer:STATE_CLOSED`)
    # + return - If success, returns nill, else returns an `error`
    public remote function printPullRequestList(string githubUser, string state) returns error? {
        log:printInfo("Preparing GitHub pull request report for user:" + githubUser + " & " + state);

        map<string[]> responseMap = {};
        string requestPath = SEARCH_API + TYPE_PR + PLUS + AUTHOR + githubUser + PLUS + state;
        var response = self->prepareMapForGitHub(requestPath, responseMap);
        if (response is ()) {
            io:println("---");
            io:println("Report of the GitHub Pull Requests");
            io:println("• GitHub User   : " + githubUser);
            io:println("• State         : " + state);
            io:println("• Total PR Count: " + self.totalCount.toString());
            io:println("---");
            printGitHubDataMap(responseMap);
            return ();
        } else {
            log:printError("Error while calling the GitHub REST API.", err = response);
            return <@untainted> response;
        }
    }

    # Prints the issue URLs of given state, that the given user involves in.
    # API Doc: https://developer.github.com/v3/search/#search-issues
    #
    # + githubUser - GitHub username
    # + state - GitHub state (`committer:STATE_ALL`, `committer:STATE_OPEN`, `committer:STATE_CLOSED`)
    # + return - If success, returns nill, else returns an `error`
    public remote function printIssueList(string githubUser, string state) returns error? {
        log:printInfo("Preparing GitHub issue report for user:" + githubUser + " & " + state);

        map<string[]> responseMap = {};
        string requestPath = SEARCH_API + TYPE_ISSUE + PLUS + INVOLVES + githubUser + PLUS + state;
        var response = self->prepareMapForGitHub(requestPath, responseMap);
        if (response is ()) {
            io:println("---");
            io:println("Report of the GitHub Issues");
            io:println("• GitHub User       : " + githubUser);
            io:println("• State             : " + state);
            io:println("• Total Issue Count : " + self.totalCount.toString());
            io:println("---");
            printGitHubDataMap(responseMap);
            return ();
        } else {
            log:printError("Error while calling the GitHub REST API.", err = response);
            return <@untainted> response;
        }
    }

    # Prints the emails excluding the given given emails, that the given user involves in
    #
    # + userEmail - User email address
    # + excludeEmails - List of emails that need to be excluded from 'to' list
    # + return - If success, returns nill, else returns an `error`
    public remote function printEmailList(string userEmail, string[]? excludeEmails) returns error? {
        log:printInfo("Preparing EMail report for user:" + userEmail);

        string queryParams = buildQueryParams(userEmail, excludeEmails);
        gmail:MsgSearchFilter searchFilter = { includeSpamTrash: false, maxResults: MAX_LIST_SIZE, q: queryParams };
        var threadList = self.gmailClient->listThreads(ME, searchFilter);
        if (threadList is gmail:ThreadListPage) {
            io:println("---");
            io:println("Report of the EMails");
            io:println("• EMail User        : " + userEmail);
            io:println("• Search Filter     : " + queryParams);
            io:println("• Total Email Count : " + threadList.resultSizeEstimate);
            io:println("---");
            io:print("Processing .");
            string[] initiatedEmails = [];
            string[] contributedEmails = [];
            foreach var thread in threadList.threads {
                var threadInfo = self.gmailClient->readThread(ME, <@untainted> thread.threadId.toString(), gmail:FORMAT_METADATA, [SUBJECT]);
                if (threadInfo is gmail:Thread) {
                    string subject = threadInfo.messages[0].headerSubject.toString();
                    if (subject == EMPTY_STRING) {
                        subject = NO_SUBJECT;
                    }
                    string[] labels = threadInfo.messages[0].labelIds;
                    boolean isInitiatedEmail = false;
                    foreach string label in labels {
                        if (stringutils:contains(label, INBOX)) {
                            isInitiatedEmail = true;
                            break;
                        }
                    }
                    if (isInitiatedEmail) {
                        initiatedEmails[initiatedEmails.length()] = subject;
                    } else {
                        contributedEmails[contributedEmails.length()] = subject;
                    }
                    io:print(".");
                } else {
                    return <@untainted> threadInfo;
                }
            }
            io:println(" ✔\n---");
            printGmailDataList(initiatedEmails, "INITIATED EMAILS");
            printGmailDataList(contributedEmails, "CONTRIBUTED EMAILS");
            return ();
        } else {
            log:printError("Error while calling the GMail connector - listThreads API.", err = threadList);
            return <@untainted> threadList;
        }
    }

    // Prepare map by recursively calling the GitHub search API
    remote function prepareMapForGitHub(string requestPath, @tainted map<string[]> responseMap) returns @tainted error? {
        http:Client httpClient = self.gitHubClient;
        var response = httpClient->get(requestPath + "&access_token=" + self.gitHubToken);
        if (response is http:Response) {
            json payload = check response.getJsonPayload();
            if (payload.total_count is error) {
                error err = error("Error while preparing map by recursive API calls.", message = payload.message.toString());
                return err;
            }
            self.totalCount = <@untainted> <int>payload.total_count;
            json[] itemList = <json[]>payload.items;
            foreach json item in itemList {
                string repoUrl = item.repository_url.toString();
                string htmlUrl = item.html_url.toString();
                addToMap(responseMap, repoUrl, htmlUrl);
            }

            if (response.hasHeader(LINK_HEADER)) {
                string linkHeader = response.getHeader(LINK_HEADER);
                string nextResourcePath = getNextResourcePath(linkHeader);
                // Check for the next page exists.
                if (nextResourcePath != EMPTY_STRING) {
                    return self->prepareMapForGitHub(nextResourcePath, responseMap);
                }
            }
            return ();
        } else {
            return response;
        }
    }
};

# Object for committer report configuration.
#
# + githubToken - The GitHub personal access token
# + gmailAccessToken - The Gmail access token
# + gmailClientId - The Gmail client id
# + gmailClientSecret - The Gmail client secret
# + gmailRefreshToken - The Gmail refresh token
public type CommitterReportConfiguration record {
    string githubToken = "";
    string gmailAccessToken = "";
    string gmailClientId = "";
    string gmailClientSecret = "";
    string gmailRefreshToken = "";
};
