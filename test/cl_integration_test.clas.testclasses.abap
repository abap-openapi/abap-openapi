CLASS ltcl_json DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS petstore_loginuser FOR TESTING RAISING cx_static_check.
    METHODS github_pulls_list FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_json IMPLEMENTATION.
  METHOD petstore_loginuser.

    DATA li_client TYPE REF TO if_http_client.
    DATA li_petstore TYPE REF TO zif_petstore.

    cl_http_client=>create_by_url(
      EXPORTING
        url    = 'https://petstore3.swagger.io'
        ssl_id = 'ANONYM'
      IMPORTING
        client = li_client ).

    CREATE OBJECT li_petstore TYPE zcl_petstore
      EXPORTING
        ii_client = li_client.

    li_petstore->getuserbyname( 'user1' ).

* todo, add assertions here
  ENDMETHOD.

  METHOD github_pulls_list.

    DATA li_client TYPE REF TO if_http_client.
    DATA li_github TYPE REF TO zif_github.

    cl_http_client=>create_by_url(
      EXPORTING
        url    = 'https://api.github.com'
        ssl_id = 'ANONYM'
      IMPORTING
        client = li_client ).

    CREATE OBJECT li_github TYPE zcl_github
      EXPORTING
        ii_client = li_client.

    " li_github->pulls_list(
    "   owner = 'abapGit'
    "   repo  = 'abapGit' ).

* todo, add assertions here
  ENDMETHOD.

ENDCLASS.