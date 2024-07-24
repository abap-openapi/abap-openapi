CLASS zcl_icf_serv008 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: intf_return_struc_component_types
* Description: intf_return_struc_component_types
* Version: 1.0.11
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_icf_serv008 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler      TYPE REF TO zif_interface008.
    DATA lv_method       TYPE string.
    DATA lv_path         TYPE string.
    DATA lv_handler_path TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl008.
    lv_path = server->request->get_header_field( '~path' ).
    REPLACE FIRST OCCURRENCE OF zif_interface008=>base_path IN lv_path WITH ''.
    lv_method = server->request->get_method( ).

    TRY.
        IF lv_path = '/pet/findByStatus' AND lv_method = 'GET'.
          DATA r_findpetsbystatus TYPE zif_interface008=>r_findpetsbystatus.
          r_findpetsbystatus = li_handler->findpetsbystatus( server->request->get_form_field( 'status' ) ).
          IF r_findpetsbystatus-_200_app_json IS NOT INITIAL.
            server->response->set_content_type( 'application/json' ).
            server->response->set_cdata( /ui2/cl_json=>serialize( r_findpetsbystatus-_200_app_json ) ).
            server->response->set_status( code = 200 reason = 'successful operation' ).
            RETURN.
          ENDIF.
          IF r_findpetsbystatus-_200_app_xml IS NOT INITIAL.
            server->response->set_content_type( 'application/xml' ).
            server->response->set_cdata( /ui2/cl_json=>serialize( r_findpetsbystatus-_200_app_xml ) ).
            server->response->set_status( code = 200 reason = 'successful operation' ).
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