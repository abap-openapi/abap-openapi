# ABAP OpenAPI Client & Server Generator

ABAP OpenAPI is an [OpenAPI](https://www.openapis.org) generator tool designed to create API clients, ICF server handlers, and ICF server implementation stubs from OpenAPI documents.

## Generate

It is possible to generate the objects using different processes:
- Generate via our [web client](https://abap-openapi.github.io/web-openapi-client/)
- Generate via command line (NodeJS)
- Generate via ABAP

## Features

| Feature |  |
| --- | --- |
| OpenAPI File Types | JSON |
| OpenAPI Versions | v2\*, v3 |
| ABAP Versions | v702 and up  |
| Object Creation | one self-contained global class & interface per OpenAPI definition |

\* OpenAPI v2 is currently only cabable by converting the v2 file to a v3 file. This can be done manually using the [Swagger Editor](https://editor.swagger.io/), or programmatically using [Swagger Converter](https://github.com/swagger-api/swagger-converter)

NOTE: generated code currently uses ZCL_OAPI_JSON, suggest copying the implementation to a local class in the generated global class

## Use Cases
### API Creator
- Write the OpenAPI document for your API so that you can generate the ICF handler and Server Implementation boilerplate
- Use the OpenAPI document to create automatic documentation for your API

### API User
- Use any OpenAPI document to create the client class to consume external APIs

## Building/Developing
### Prerequisites
[NodeJS](https://nodejs.org) 16+

### Setup 
- clone this repository
- run `npm install`

`npm test` = run unit tests

`npm run petstore` = run logic and generate petstore files in `./test_v1/generated/`

`npm run integration_test` = run integration tests