INTERFACE zif_interface020 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: any table body
* Version: 1

  CONSTANTS base_path TYPE string VALUE ''.

* bodysend
  TYPES bodysend TYPE string. " array  todo

  METHODS send
    IMPORTING
      body TYPE bodysend
    RAISING
      cx_static_check.
ENDINTERFACE.