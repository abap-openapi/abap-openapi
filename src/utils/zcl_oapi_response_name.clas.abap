CLASS zcl_oapi_response_name DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS
      generate_response_name
        IMPORTING
          iv_content_type TYPE zif_oapi_specification_v3=>ty_media_type-type
          iv_code         TYPE zif_oapi_specification_v3=>ty_response-code
        RETURNING
          VALUE(rv_name)  TYPE string.

  PROTECTED SECTION.


  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_content_type,
        primary   TYPE string,
        secondary TYPE string,
      END OF ty_content_type.

    METHODS:
      parse_content_name
        IMPORTING
          iv_name          TYPE string
        RETURNING
          VALUE(rs_result) TYPE ty_content_type.

    METHODS:
      condense_primary_name
        IMPORTING
          iv_name          TYPE string
        RETURNING
          VALUE(rv_result) TYPE string.

    METHODS:
      condense_secondary_name
        IMPORTING
          iv_name          TYPE string
        RETURNING
          VALUE(rv_result) TYPE string.
ENDCLASS.



CLASS zcl_oapi_response_name IMPLEMENTATION.


  METHOD condense_primary_name.
    CASE iv_name.
      WHEN 'application'.
        rv_result = 'app'.
      WHEN 'audio'.
        rv_result = 'aud'.
      WHEN 'font'.
        rv_result = 'fnt'.
      WHEN 'example'.
        rv_result = 'exm'.
      WHEN 'image'.
        rv_result = 'img'.
      WHEN 'message'.
        rv_result = 'msg'.
      WHEN 'model'.
        rv_result = 'mdl'.
      WHEN 'multipart'.
        rv_result = 'mp'.
      WHEN 'text'.
        rv_result = 'txt'.
      WHEN 'video'.
        rv_result = 'vid'.
      WHEN OTHERS.
        rv_result = iv_name(3).
    ENDCASE.
  ENDMETHOD.


  METHOD condense_secondary_name.

    DATA lv_type TYPE string.
    DATA lv_descriptor_full TYPE string.
    DATA lv_descriptor_primary TYPE string.
    DATA lv_descriptor_secondary TYPE string.

    SPLIT iv_name AT '+' INTO lv_descriptor_full lv_type.

*    REPLACE ALL OCCURRENCES OF REGEX '[aeiouy]' IN lv_descriptor_full WITH ''.

    SPLIT lv_descriptor_full AT '-' INTO lv_descriptor_primary lv_descriptor_secondary.

    IF lv_descriptor_primary <> space.
      rv_result = lv_descriptor_primary.

      IF lv_descriptor_secondary <> space.
        rv_result = |{ rv_result }_{ lv_descriptor_secondary(3) }|.
      ENDIF.

      IF lv_type <> space.
        rv_result = |{ rv_result }_{ lv_type }|.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD parse_content_name.
    SPLIT iv_name AT '/' INTO rs_result-primary rs_result-secondary.
  ENDMETHOD.


  METHOD generate_response_name.

    DATA lv_name         TYPE string.
    DATA ls_content_type TYPE ty_content_type.
    DATA lo_abap_name    TYPE REF TO zcl_oapi_abap_name.

    ls_content_type = parse_content_name( iv_content_type ).
    lv_name = |{ condense_primary_name( ls_content_type-primary ) }_{ condense_secondary_name( ls_content_type-secondary ) }|.

    CREATE OBJECT lo_abap_name.

    lv_name = lo_abap_name->to_abap_name( lv_name ).

    rv_name = |_{ iv_code }_{ lv_name }|.

  ENDMETHOD.
ENDCLASS.
