![](images/logo.svg)

## POST a request, 🪄 get a password 🪄!

A REST API written in [Node.js](https://nodejs.org/en) wth [TypeScript](https://www.typescriptlang.org/) deployed to [AWS Elastic Beanstalk](https://aws.amazon.com/elasticbeanstalk/)
via [AWS CodePipeline](https://aws.amazon.com/codepipeline/).


### 🌐 Health Check Endpoint

**Request:**

Send a `GET` to the root endpoint `/`

**Response:**

If there are no problems with the server, it will simply respond with `OK` (HTTP 200)
when sending a `GET` request to the root endpoint.

### 🌐 Password Generation Endpoint

Request:

Send a `POST` request to the `/v1/passwords` endpoint with a JSON body with the following options.

```
{
    "length": 12,
    "includeNumbers": "true",
    "includeUppercase": "true",
    "includeLowercase": "true",
    "includeSpecialCharacters": "true",
}
```

**length**: A number between 6 and 64. Password length will default to 12 if the length is outside this range.

**includeNumbers**: Include the numbers `0123456789` as possible characters in the password.

**includeUppercase**: Include uppercase letters of the [ASCII alphabet](https://en.wikipedia.org/wiki/ASCII).

**includeLowercase**: Include lowercase letters of the [ASCII alphabet](https://en.wikipedia.org/wiki/ASCII).

**includeSpecialCharacters**: Include special characters `!@#$%^&*-_=+<>?;:[]{}(),./|` in the possible characters for the password.

> If an options is omitted, PWB0T assumes you meant `true`, those characters will be included in the possible password.
