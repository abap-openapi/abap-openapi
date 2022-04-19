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
    METHODS pulls_create FOR TESTING RAISING cx_static_check.
    METHODS pulls_update FOR TESTING RAISING cx_static_check.
    DATA mi_github TYPE REF TO zif_github.
    DATA mv_token TYPE string.
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

    li_client->request->set_header_field(
      name  = 'user-agent'
      value = 'abap-openapi-client-integration-test' ).

    WRITE '@KERNEL this.mv_token.set(process.env.GITHUB_TOKEN || "");'.
    IF mv_token IS NOT INITIAL.
      li_client->authenticate(
        username = 'dummy'
        password = mv_token ).
    ENDIF.

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
      act = ls_pull_request-html_url
      exp = 'https://github.com/abapGit-tests/VIEW/pull/1' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_pull_request-mergeable_state
      exp = 'dirty' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_pull_request-head-ref
      exp = 'hvam/test1' ).

  ENDMETHOD.

  METHOD pulls_create.

    DATA ls_body TYPE zif_github=>bodypulls_create.
    DATA ls_created TYPE zif_github=>pull_request.

    IF mv_token IS INITIAL.
      RETURN.
    ENDIF.

    ls_created = mi_github->pulls_create(
      owner = 'larshp'
      repo  = 'testing-test'
      body  = ls_body ).

    WRITE '@KERNEL console.dir(ls_created);'.

    cl_abap_unit_assert=>assert_not_initial( ls_created ).

  ENDMETHOD.

  METHOD pulls_update.
    " DATA ls_body TYPE zif_github=>bodypulls_update.
    " DATA ls_pull_request TYPE zif_github=>pull_request.

    " IF mv_token IS INITIAL.
    "   RETURN.
    " ENDIF.

    " ls_body-title = 'abc_title'.
    " ls_body-body  = 'abc_body'.
    " ls_body-state = 'open'.
    " ls_body-base  = 'sdfsdf'.
    " ls_body-maintainer_can_modify = abap_true.

    " ls_pull_request = mi_github->pulls_update(
    "   owner       = 'larshp'
    "   repo        = 'testing-test'
    "   pull_number = 2
    "   body        = ls_body ).

    " cl_abap_unit_assert=>assert_equals(
    "   act = ls_pull_request-url
    "   exp = 'https://api.github.com/repos/larshp/testing-test/pulls/2' ).
  ENDMETHOD.

  METHOD pulls_list.

    DATA lt_pulls TYPE zif_github=>response_pulls_list.
    DATA ls_pull LIKE LINE OF lt_pulls.

    lt_pulls = mi_github->pulls_list(
      owner = 'abapGit-tests'
      repo  = 'VIEW' ).

"     cl_abap_unit_assert=>assert_equals(
"       act = lines( lt_pulls )
"       exp = 1 ).

"     READ TABLE lt_pulls INDEX 1 INTO ls_pull.
"     cl_abap_unit_assert=>assert_subrc( ).

" *    WRITE '@KERNEL console.dir(ls_pull);'.

"     cl_abap_unit_assert=>assert_equals(
"       act = ls_pull-url
"       exp = 'https://api.github.com/repos/abapGit-tests/VIEW/pulls/1' ).

"     cl_abap_unit_assert=>assert_equals(
"       act = ls_pull-title
"       exp = 'VIEW format updates' ).

  ENDMETHOD.

ENDCLASS.