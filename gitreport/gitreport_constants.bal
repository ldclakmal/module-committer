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

// Symbols
@final string EMPTY_STRING = "";
@final string SEMICOLON = ";";
@final string PLUS = "+";
@final string COMMA = ",";
@final string FORWARD_SLASH = "/";

// ---- GitHub related constants ----

// API URLs
@final string API_BASE_URL = "https://api.github.com";
@final string SEARCH_API = "/search/issues?q=";
@final string REPOS = "/repos/";

// API Response related parameters
@final string LINK_HEADER = "Link";
@final string NEXT_REALTION = "rel=\"next\"";
@final string LAST_RELATION = "rel=\"last\"";

// PR status
@final string STATE_ALL = "state:open+state:closed";
@final string STATE_OPEN = "state:open";
@final string STATE_CLOSED = "state:closed";

// Issue type
@final string TYPE_ISSUE = "type:issue";
@final string TYPE_PR = "type:pr";

// Author query param
@final string AUTHOR = "author:";
@final string INVOLVES = "involves:";

// ---- GMail related constants ----
@final string ME = "me";
@final string SUBJECT = "Subject";
@final string NO_SUBJECT = "(no subject)";
