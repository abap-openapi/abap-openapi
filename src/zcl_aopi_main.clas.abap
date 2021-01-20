CLASS zcl_aopi_main DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS parse_json IMPORTING iv_json TYPE string.
ENDCLASS.

CLASS zcl_aopi_main IMPLEMENTATION.

  METHOD run.
    parse_json( iv_json ).

    rs_result-clas =
      |CLASS zcl_bar DEFINITION PUBLIC.\n| &&
      |ENDCLASS.\n| &&
      |CLASS zcl_bar IMPLEMENTATION.\n| &&
      |ENDCLASS.|.

    rs_result-intf = |INTERFACE zif_bar.\n| &&
      |ENDINTERFACE.|.
  ENDMETHOD.

  METHOD parse_json.

    DATA li_node TYPE REF TO if_sxml_node.
    DATA li_reader TYPE REF TO if_sxml_reader.
    li_reader = cl_sxml_string_reader=>create( cl_abap_codepage=>convert_to( iv_json ) ).

    DO.
      li_node = li_reader->read_next_node( ).
      IF li_node IS INITIAL.
        EXIT.
      ENDIF.
      WRITE: / 'node type:', li_node->type.
    ENDDO.

  ENDMETHOD.

ENDCLASS.