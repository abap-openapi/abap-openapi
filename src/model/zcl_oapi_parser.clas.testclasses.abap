CLASS ltcl_parser DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS path_clashes_with_method FOR TESTING RAISING cx_static_check.
    METHODS nullable_any_of FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_parser IMPLEMENTATION.
  METHOD path_clashes_with_method.
* https://github.com/abap-openapi/abap-openapi/issues/245
* "/project/{id}" + "delete" and "/project/{id}/delete" must not be mixed up
    DATA lo_parser    TYPE REF TO zcl_oapi_parser.
    DATA ls_spec      TYPE zif_oapi_specification_v3=>ty_specification.
    DATA ls_operation LIKE LINE OF ls_spec-operations.
    DATA lv_json      TYPE string.

    lv_json = `{"openapi": "3.0.1", "info": {"title": "t", "version": "1"}, "paths": {` &&
      `"/project/{id}": {"delete": {"operationId": "deleteProject", "deprecated": false, "tags": ["x"],` &&
      `"responses": {"204": {"description": "ok"}}}},` &&
      `"/project/{id}/delete": {"post": {"operationId": "deleteProjectAsync",` &&
      `"responses": {"303": {"description": "ok", "content": {"application/json": {"schema": {"type": "string"}}}}}}}}}`.

    CREATE OBJECT lo_parser.
    ls_spec = lo_parser->parse( lv_json ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_spec-operations )
      exp = 2 ).

    READ TABLE ls_spec-operations INTO ls_operation WITH KEY path = '/project/{id}'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_operation-method
      exp = 'delete' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_operation-operation_id
      exp = 'deleteProject' ).

    READ TABLE ls_spec-operations INTO ls_operation WITH KEY path = '/project/{id}/delete'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_operation-method
      exp = 'post' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_operation-operation_id
      exp = 'deleteProjectAsync' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_operation-responses )
      exp = 1 ).
  ENDMETHOD.

  METHOD nullable_any_of.
* OpenAPI 3.1 style nullable, "anyOf": [X, {"type": "null"}] is parsed as X
    DATA lo_parser    TYPE REF TO zcl_oapi_parser.
    DATA ls_spec      TYPE zif_oapi_specification_v3=>ty_specification.
    DATA ls_operation LIKE LINE OF ls_spec-operations.
    DATA ls_parameter LIKE LINE OF ls_operation-parameters.
    DATA ls_schema    LIKE LINE OF ls_spec-components-schemas.
    DATA ls_property  TYPE zif_oapi_schema=>ty_property.
    DATA lv_json      TYPE string.

    lv_json = `{"openapi": "3.1.0", "info": {"title": "t", "version": "1"}, "paths": {` &&
      `"/items": {"get": {"operationId": "listItems", "parameters": [` &&
      `{"name": "cursor", "in": "query", "schema": {"anyOf": [{"type": "string"}, {"type": "null"}]}},` &&
      `{"name": "limit", "in": "query", "schema": {"oneOf": [{"type": "null"}, {"type": "integer"}], "default": 50}}],` &&
      `"responses": {"200": {"description": "ok"}}}}},` &&
      `"components": {"schemas": {` &&
      `"Owner": {"type": "object", "properties": {"name": {"type": "string"}}},` &&
      `"Item": {"type": "object", "properties": {` &&
      `"note": {"anyOf": [{"type": "string"}, {"type": "null"}]},` &&
      `"owner": {"anyOf": [{"$ref": "#/components/schemas/Owner"}, {"type": "null"}]},` &&
      `"either": {"anyOf": [{"type": "string"}, {"type": "integer"}]}}}}}}`.

    CREATE OBJECT lo_parser.
    ls_spec = lo_parser->parse( lv_json ).

    READ TABLE ls_spec-operations INTO ls_operation WITH KEY operation_id = 'listItems'.
    cl_abap_unit_assert=>assert_subrc( ).
    READ TABLE ls_operation-parameters INTO ls_parameter WITH KEY name = 'cursor'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameter-schema->type
      exp = 'string' ).
    READ TABLE ls_operation-parameters INTO ls_parameter WITH KEY name = 'limit'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameter-schema->type
      exp = 'integer' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameter-schema->default
      exp = '50' ).

    READ TABLE ls_spec-components-schemas INTO ls_schema WITH KEY name = 'Item'.
    cl_abap_unit_assert=>assert_subrc( ).
    READ TABLE ls_schema-schema->properties INTO ls_property WITH KEY name = 'note'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_property-schema->type
      exp = 'string' ).
    READ TABLE ls_schema-schema->properties INTO ls_property WITH KEY name = 'owner'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_property-ref
      exp = '#/components/schemas/Owner' ).
* a real union is not "X or null", it keeps the existing handling
    READ TABLE ls_schema-schema->properties INTO ls_property WITH KEY name = 'either'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_property-schema->type
      exp = 'object' ).
  ENDMETHOD.
ENDCLASS.
