INTERFACE zif_interface011 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: path parameter
* Description: path parameter
* Version: 1

  CONSTANTS base_path TYPE string VALUE ''.

  METHODS _foo_param
    IMPORTING
      param TYPE string
    RAISING
      cx_static_check.
ENDINTERFACE.