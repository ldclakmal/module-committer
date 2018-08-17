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

import ballerina/io;

documentation{
    Return the next URL and last URL after clearing the given link header with other symbols
    `Link: <https://api.github.com/resource?page=2>; rel="next",
      <https://api.github.com/resource?page=5>; rel="last"`

    P{{linkHeader}} Link header of the request
    R{{}} Next URL and Last URL
}
function getNextAndLastResourcePaths(string linkHeader) returns (string, string) {
    string[] urlWithRelationArray = linkHeader.split(COMMA);
    string nextUrl;
    string lastUrl;
    foreach urlWithRealtion in urlWithRelationArray {
        string urlWithBrackets = urlWithRealtion.split(SEMICOLON)[0].trim();
        if (urlWithRealtion.contains(NEXT_REALTION)) {
            nextUrl = getResourcePath(urlWithRealtion);
        } else if (urlWithRealtion.contains(LAST_RELATION)) {
            lastUrl = getResourcePath(urlWithRealtion);
        }
    }
    return (nextUrl, lastUrl);
}

documentation{
    Return the resource path after clearing the given URL with other symbols

    P{{link}} Link URL with other parameters
    R{{}} Cleaned resource path
}
function getResourcePath(string link) returns string {
    string urlWithBrackets = link.split(SEMICOLON)[0].trim();
    return urlWithBrackets.substring(1, urlWithBrackets.length() - 1).replace(API_URL, EMPTY_STRING);
}

documentation{
    Print the items in the given list

    P{{list}} List to be printed
}
function printList(string[] list) {
    foreach item in list {
        io:println(item);
    }
}