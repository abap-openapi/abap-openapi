CLASS ltcl_petstore DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS setup.
    METHODS getuserbyname FOR TESTING RAISING cx_static_check.
    DATA mi_petstore TYPE REF TO zif_petstore.
ENDCLASS.

CLASS ltcl_petstore IMPLEMENTATION.

  METHOD setup.

    DATA li_client TYPE REF TO if_http_client.

    cl_http_client=>create_by_url(
      EXPORTING
        url    = 'https://petstore3.swagger.io'
        ssl_id = 'ANONYM'
      IMPORTING
        client = li_client ).

    CREATE OBJECT mi_petstore TYPE zcl_petstore
      EXPORTING
        ii_client = li_client.

  ENDMETHOD.

  METHOD getuserbyname.

    DATA ls_user TYPE zif_petstore=>user.

    ls_user = mi_petstore->getuserbyname( 'user1' ).

    cl_abap_unit_assert=>assert_not_initial( ls_user ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_user-username
      exp = 'user1' ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_github DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS setup.
    METHODS gists_get FOR TESTING RAISING cx_static_check.
    METHODS pulls_list FOR TESTING RAISING cx_static_check.
    METHODS pulls_get FOR TESTING RAISING cx_static_check.
    DATA mi_github TYPE REF TO zif_github.
ENDCLASS.

CLASS ltcl_github IMPLEMENTATION.

  METHOD setup.

    DATA li_client TYPE REF TO if_http_client.

    cl_http_client=>create_by_url(
      EXPORTING
        url    = 'https://api.github.com'
        ssl_id = 'ANONYM'
      IMPORTING
        client = li_client ).

    CREATE OBJECT mi_github TYPE zcl_github
      EXPORTING
        ii_client = li_client.

  ENDMETHOD.

  METHOD gists_get.

    DATA ls_gist TYPE zif_github=>gist_simple.

    ls_gist = mi_github->gists_get( '71609852a79aa1e877f8c4020d18feac' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_gist-html_url
      exp = 'https://gist.github.com/71609852a79aa1e877f8c4020d18feac' ).

  ENDMETHOD.

  METHOD pulls_get.

    DATA ls_pull_request TYPE zif_github=>pull_request.

    ls_pull_request = mi_github->pulls_get(
       owner       = 'abapGit-tests'
       repo        = 'VIEW'
       pull_number = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_pull_request-url
      exp = 'https://api.github.com/repos/abapGit-tests/VIEW/pulls/1' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_pull_request-mergeable_state
      exp = 'clean' ).

* todo,    ls_pull_request-head-ref

  ENDMETHOD.

  METHOD pulls_list.
    " mi_github->pulls_list(
    "   owner = 'abapGit'
    "   repo  = 'abapGit' ).

  ENDMETHOD.

ENDCLASS.