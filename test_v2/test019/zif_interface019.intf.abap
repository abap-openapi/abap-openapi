INTERFACE zif_interface019 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: binary body
* Version: 1

  CONSTANTS base_path TYPE string VALUE ''.

  TYPES: BEGIN OF r_send_binary,
           code          TYPE i,
           reason        TYPE string,
         END OF r_send_binary.
  METHODS send_binary
    IMPORTING
      body TYPE xstring
    RETURNING
      VALUE(return) TYPE r_send_binary
    RAISING
      cx_static_check.
ENDINTERFACE.
