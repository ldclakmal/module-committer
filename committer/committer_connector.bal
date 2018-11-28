import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import wso2/gmail;

int totalCount = 0;

public type CommitterReportConnector client object {

    public http:Client committerReportClient;
    public gmail:Client gmailClient;

    public function __init(string url, CommitterReportConfiguration? committerReportConfig) {
        self.committerReportClient = new(url);
        self.gmailClient = new(committerReportConfig.clientConfig);
    }

    remote function printPullRequestList(string githubUser, string state) returns error?;

    remote function printIssueList(string githubUser, string state) returns error?;

    remote function printEmailList(string userEmail, string[]? excludeEmails) returns error?;
};

// API Doc: https://developer.github.com/v3/search/#search-issues
remote function CommitterReportConnector.printPullRequestList(string githubUser, string state) returns error? {

    log:printInfo("Preparing GitHub pull request report for user:" + githubUser + " & " + state);

    map<string[]> responseMap = {};
    string requestPath = SEARCH_API + TYPE_PR + PLUS + AUTHOR + githubUser + PLUS + state;
    var response = prepareMapForGitHUb(self.committerReportClient, requestPath, responseMap);
    if (response is ()) {
        io:println("---");
        io:println("Report of the GitHub Pull Requests");
        io:println("• GitHub User   : " + githubUser);
        io:println("• State         : " + state);
        io:println("• Total PR Count: " + totalCount);
        io:println("---");
        printGitHubDataMap(responseMap);
        return ();
    } else {
        log:printError("Error while calling the GitHub REST API", err = response);
        return response;
    }
}

// API Doc: https://developer.github.com/v3/search/#search-issues
remote function CommitterReportConnector.printIssueList(string githubUser, string state) returns error? {

    log:printInfo("Preparing GitHub issue report for user:" + githubUser + " & " + state);

    map<string[]> responseMap = {};
    string requestPath = SEARCH_API + TYPE_ISSUE + PLUS + INVOLVES + githubUser + PLUS + state;
    var response = prepareMapForGitHUb(self.committerReportClient, requestPath, responseMap);
    if (response is ()) {
        io:println("---");
        io:println("Report of the GitHub Issues");
        io:println("• GitHub User       : " + githubUser);
        io:println("• State             : " + state);
        io:println("• Total Issue Count : " + totalCount);
        io:println("---");
        printGitHubDataMap(responseMap);
        return ();
    } else {
        log:printError("Error while calling the GitHub REST API", err = response);
        return response;
    }
}

remote function CommitterReportConnector.printEmailList(string userEmail, string[]? excludeEmails) returns error? {

    log:printInfo("Preparing EMail report for user:" + userEmail);

    string queryParams = buildQueryParams(userEmail, excludeEmails);
    gmail:MsgSearchFilter searchFilter = { includeSpamTrash: false, maxResults: MAX_LIST_SIZE, q: queryParams };
    var threadList = self.gmailClient->listThreads(ME, filter = searchFilter);
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
        foreach i, thread in threadList.threads {
            var threadInfo = gmailClient->readThread(ME, <string>thread.threadId, format = gmail:FORMAT_METADATA,
                metadataHeaders = [SUBJECT]);
            if (threadInfo is gmail:Thread) {
                string subject = <string>threadInfo.messages[0].headerSubject;
                if (subject == EMPTY_STRING) {
                    subject = NO_SUBJECT;
                }
                string[] labels = threadInfo.messages[0].labelIds;
                boolean isInitiatedEmail = false;
                foreach label in labels {
                    if (label.contains(INBOX)) {
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
                return threadInfo;
            }
        }
        io:println(" ✔\n---");
        printGmailDataList(initiatedEmails, "INITIATED EMAILS");
        printGmailDataList(contributedEmails, "CONTRIBUTED EMAILS");
        return ();
    } else {
        log:printError("Error while calling the GMail connector - listThreads API", err = threadList);
        return threadList;
    }
}

// Prepare map by recursively calling the GitHub search API
function prepareMapForGitHUb(http:Client committerReportClient, string requestPath, map<string[]> responseMap)
             returns error? {
    http:Client httpClient = committerReportClient;
    var response = httpClient->get(requestPath);
    if (response is http:Response) {
        json payload = check response.getJsonPayload();
        totalCount = untaint <int>payload.total_count;
        json[] itemList = <json[]>payload.items;
        foreach item in itemList {
            string repoUrl = <string>item.repository_url;
            string htmlUrl = <string>item.html_url;
            addToMap(responseMap, repoUrl, htmlUrl);
        }

        if (response.hasHeader(LINK_HEADER)) {
            string linkHeader = response.getHeader(LINK_HEADER);
            string nextResourcePath = getNextResourcePath(linkHeader);
            // Check for the next page exists.
            if (nextResourcePath != EMPTY_STRING) {
                return prepareMapForGitHUb(committerReportClient, nextResourcePath, responseMap);
            }
        }
        return ();
    } else {
        return response;
    }
}
