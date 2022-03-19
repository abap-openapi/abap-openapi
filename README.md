# abap-openapi

ABAP [OpenAPI](https://www.openapis.org) Client & Server Generator in ABAP

- [possibility to run in browser](https://abap-openapi.github.io/web-openapi-client/)
- possibility to run via command line(NodeJS)
- possibility to generate for different ABAP versions(ie. Steampunk)
- one self-contained global class + interface per OpenAPI definition
- possible to run generation on ABAP stack
- eventually OpenAPI v2 support, [converting v2 to v3](https://github.com/swagger-api/swagger-converter)
- only JSON support

NOTE: generated code currently uses ZCL_OAPI_JSON, suggest copying the implementation to a local class in the generated global class

Generation is targeted to run on v702

Generated client code is targeted to run on v702

## Building/Developing
Prerequisites = [NodeJS](https://nodejs.org) 16+

setup `npm install`

`npm test` = run unit tests

`npm run petstore` = run logic and generate petstore files in `./result/`

`npm run integration_test` = run integration tests