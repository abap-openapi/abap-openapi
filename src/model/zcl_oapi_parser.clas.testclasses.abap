CLASS ltcl_parser DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS path_clashes_with_method FOR TESTING RAISING cx_static_check.
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
ENDCLASS.
