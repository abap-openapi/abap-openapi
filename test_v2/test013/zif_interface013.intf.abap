INTERFACE zif_interface013 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: two path parameters
* Version: 1

  CONSTANTS base_path TYPE string VALUE ''.

  TYPES: BEGIN OF r__foo_param_another,
           code          TYPE i,
           reason        TYPE string,
         END OF r__foo_param_another.
  METHODS _foo_param_another
    IMPORTING
      param TYPE string
      another TYPE string
    RETURNING
      VALUE(return) TYPE r__foo_param_another
    RAISING
      cx_static_check.
ENDINTERFACE.
