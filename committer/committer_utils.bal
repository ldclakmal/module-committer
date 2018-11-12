import ballerina/io;

# Return the untainted next URL after clearing the given link header with other symbols. If next URL is not given,
# returns an empty string, which represents the last page
# `Link: <https://api.github.com/resource?page=2>; rel="next", <https://api.github.com/resource?page=5>; rel="last"`
#
# + linkHeader - Link header of the request
# + return - Next URL and Last URL
function getNextResourcePath(string linkHeader) returns @untainted string {
    string[] urlWithRelationArray = linkHeader.split(COMMA);
    string nextUrl;
    foreach urlWithRealtion in urlWithRelationArray {
        string urlWithBrackets = urlWithRealtion.split(SEMICOLON)[0].trim();
        if (urlWithRealtion.contains(NEXT_REALTION)) {
            nextUrl = getResourcePath(urlWithRealtion);
        }
    }
    return nextUrl;
}

# Return the resource path after clearing the given URL with other symbols
#
# + link - Link URL with other parameters
# + return - Cleaned resource path
function getResourcePath(string link) returns string {
    string urlWithBrackets = link.split(SEMICOLON)[0].trim();
    return urlWithBrackets.substring(1, urlWithBrackets.length() - 1).replace(API_BASE_URL, EMPTY_STRING);
}

# Return the build query parametrs for GMail API
#
# + userEmail - User email for 'from' parameter
# + excludeEmails - List of emails to be excluded from 'to' parameter
# + return - Built string with query parameters
function buildQueryParams(string userEmail, string[]? excludeEmails) returns string {
    string queryParams = "from:" + userEmail;
    match excludeEmails {
        string[] list => {
            queryParams += " to:(";
            foreach email in list {
                queryParams += " -" + email;
            }
            queryParams += ")";
        }
        () => {}
    }
    queryParams += " -in:chats";
    return queryParams;
}

# Add the given key and value to the given map
#
# + m - Map, the value to be added
# + key - Key of the value
# + value - Actual value to be added
function addToMap(map<string[]> m, string key, string value) {
    if (m.hasKey(key)) {
        string[] valueArray = m[key] but { () => []};
        valueArray[lengthof valueArray] = value;
    } else {
        string[] valueArray = [value];
        m[key] = valueArray;
    }
}

# Print the given GitHub data map
#
# + m - The data as a map
function printGitHubDataMap(map m) {
    foreach key in m.keys() {
        string githubOrgWithRepo = key.replace(API_BASE_URL + REPOS, EMPTY_STRING);
        string githubOrg = githubOrgWithRepo.split(FORWARD_SLASH)[0];
        string githubRepo = githubOrgWithRepo.split(FORWARD_SLASH)[1];
        io:println("GitHub Org  : " + githubOrg);
        io:println("GitHub Repo : " + githubRepo);
        string[] list = check <string[]>m[key];
        foreach item in list  {
            io:println(item);
        }
        io:println("---");
    }
}

# Print the given GMail data list
#
# + list - The data as a list
function printGmailDataList(string[] list, string category) {
    io:println("Category: " + category);
    io:println("*****************************");
    foreach item in list  {
        io:println(item);
    }
    io:println("---");
}
