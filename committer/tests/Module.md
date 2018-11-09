# Module Committer - Tests

The committer connector generates the report for WSO2 Committer Request. It allows you to list all the pull requests you sent, list all the issues you get involved and list all the emails you get involved.

## Compatibility

| Ballerina Version  |
|:------------------:|
| 0.982.0            |

## Running tests

In order to run the tests, you need to have OAuth 2.0 credentials for your GMail account. The following guide will help you get obtain the token.

[How to obtain Google OAuth2.0 Credentials](https://gist.github.com/ldclakmal/6c43ed7dfaa19d7eb0db324402d14102)

Then, you need to create a `ballerina.conf` file at module root and add the obtained token as follows.

###### ballerina.conf

```ballerina.conf
ACCESS_TOKEN="your_access_token"
CLIENT_ID="your_client_id"
CLIENT_SECRET="your_client_secret"
REFRESH_TOKEN="your_refresh_token"
```

Go to the root of the project and execute following commands.
```
ballerina init
ballerina test committer
```
