CLASS zcl_icf_serv015 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: return structured array
* Version: 1
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_icf_serv015 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler      TYPE REF TO zif_interface015.
    DATA lv_method       TYPE string.
    DATA lv_path         TYPE string.
    CREATE OBJECT li_handler TYPE zcl_icf_impl015.
    lv_path = server->request->get_header_field( '~path' ).
    REPLACE FIRST OCCURRENCE OF zif_interface015=>base_path IN lv_path WITH ''.
    lv_method = server->request->get_method( ).

    TRY.
        IF lv_path = '/array' AND lv_method = 'POST'.
          DATA r__array TYPE zif_interface015=>r__array.
          r__array = li_handler->_array( ).
          IF r__array-_200_app_json IS NOT INITIAL.
            server->response->set_content_type( 'application/json' ).
            server->response->set_cdata( /ui2/cl_json=>serialize( r__array-_200_app_json ) ).
            server->response->set_status( code = 200 reason = 'foo' ).
            RETURN.
          ENDIF.
        ENDIF.
      CATCH cx_static_check.
        server->response->set_content_type( 'text/plain' ).
        server->response->set_cdata( 'exception' ).
        server->response->set_status( code = 500 reason = 'Error' ).
    ENDTRY.

    server->response->set_content_type( 'text/plain' ).
    server->response->set_cdata( 'no handler found' ).
    server->response->set_status( code = 500 reason = 'Error' ).
  ENDMETHOD.
ENDCLASS.
