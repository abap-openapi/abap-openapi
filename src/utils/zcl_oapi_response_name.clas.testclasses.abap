*"* use this source file for your ABAP unit test classes

CLASS ltcl_content_type DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS:
      setup,
      teardown,
      run_test
        IMPORTING
          iv_content_type    TYPE zif_oapi_specification_v3=>ty_media_type-type
          iv_code            TYPE zif_oapi_specification_v3=>ty_response-code
          iv_expected_Result TYPE string,
      application_json FOR TESTING RAISING cx_static_check,
      application_xml FOR TESTING RAISING cx_static_check,
      app_1d_interleaved_prty FOR TESTING RAISING cx_static_check
      .

    DATA cut TYPE REF TO zcl_oapi_response_name.
    DATA iv_name TYPE string.
    DATA actual_result TYPE string.
    DATA expected_result TYPE string.

ENDCLASS.

CLASS ltcl_content_type IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT cut.
  ENDMETHOD.

  METHOD teardown.
    FREE cut.
  ENDMETHOD.

  METHOD run_test.
    DATA: lv_actual_result TYPE string.
    lv_actual_result = cut->generate_response_name(
                         iv_content_type = iv_content_type
                         iv_code    = iv_code
                       ).
    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act                  = lv_actual_result
        exp                  = iv_expected_result
        msg                  = 'Response name not generated correctly'
        ).

  ENDMETHOD.

  METHOD application_json.

    run_test(
        iv_content_type = 'application/json'
        iv_code    = '200'
        iv_expected_result = '_200_app_json' ).

  ENDMETHOD.

  METHOD application_xml.
    run_test(
        iv_content_type = 'application/xml'
        iv_code    = '200'
        iv_expected_result = '_200_app_xml' ).
  ENDMETHOD.

  METHOD app_1d_interleaved_prty.
    run_test(
            iv_content_type = 'application/1d-interleaved-parityfec'
            iv_code    = '200'
            iv_expected_result = '_200_app_1d_int' ).
  ENDMETHOD.

ENDCLASS.
