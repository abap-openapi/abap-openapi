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

\* OpenAPI v2 is currently only capable by converting the v2 file to a v3 file. This can be done manually using the [Swagger Editor](https://editor.swagger.io/), or programmatically using [Swagger Converter](https://github.com/swagger-api/swagger-converter)

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

### Testing
Unit Tests: `npm test`
Intergration Tests: `npm run integration_test`

You can try out the generation using Swagger's Petstore Example:
- Just run `npm run petstore`
- The output files will be generated in `./test_v1/generated/`

## Example

```sh
#!/usr/bin/env bash

rm -rf abap-openapi
git clone --depth=1 https://github.com/abap-openapi/abap-openapi
rm -rf abap-openapi/.git
cd abap-openapi
npm ci
npm run transpile
rm ../src/api/*.abap
node test_v2/index.mjs <filename> ../src/api <name>
```
