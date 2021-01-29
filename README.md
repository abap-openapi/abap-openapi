# abap-openapi-client
ABAP [OpenAPI](https://www.openapis.org) Client Generator in ABAP

- [possibility to run in browser](https://abap-openapi.github.io/web-openapi-client/)
- possibility to run via command line(NodeJS)
- possibility to generate for different ABAP versions(ie. Steampunk)
- one self-contained global class + interface per OpenAPI definition
- eventually possible to run on ABAP stack
- eventually OpenAPI v2 and v3 support

prerequsites = [NodeJS](https://nodejs.org) 12+

setup `npm install`

`npm test` = run unit tests

`npm run petstore` = run logic and generate petstore files in `./result/`

`npm run integration_test` = run integration tests
