CLASS lcl_stack DEFINITION.
  PUBLIC SECTION.
    METHODS push IMPORTING iv_name TYPE string.
    METHODS pop.
    METHODS get RETURNING VALUE(rv_path) TYPE string.
  PRIVATE SECTION.
    DATA mt_data TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
ENDCLASS.

CLASS lcl_stack IMPLEMENTATION.
  METHOD push.
    APPEND iv_name TO mt_data.
  ENDMETHOD.

  METHOD pop.
    DATA lv_index TYPE i.
    lv_index = lines( mt_data ).
    ASSERT lv_index > 0.
    DELETE mt_data INDEX lv_index.
  ENDMETHOD.

  METHOD get.
    rv_path = concat_lines_of( mt_data ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_parser DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
        parent TYPE string,
        name TYPE string,
        value TYPE string,
      END OF ty_data.

    TYPES ty_data_tt TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY.

    METHODS parse
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rt_data) TYPE ty_data_tt.
ENDCLASS.

CLASS lcl_parser IMPLEMENTATION.
  METHOD parse.

    DATA li_node TYPE REF TO if_sxml_node.
    DATA li_reader TYPE REF TO if_sxml_reader.
    DATA li_close TYPE REF TO if_sxml_close_element.
    DATA li_open TYPE REF TO if_sxml_open_element.
    DATA lt_attributes TYPE if_sxml_attribute=>attributes.
    DATA li_attribute TYPE REF TO if_sxml_attribute.
    DATA li_value TYPE REF TO if_sxml_value_node.
    DATA lv_count TYPE i.

    DATA lv_push TYPE string.
    DATA lo_stack TYPE REF TO lcl_stack.
    CREATE OBJECT lo_stack.

    CLEAR rt_data.

    li_reader = cl_sxml_string_reader=>create( cl_abap_codepage=>convert_to( iv_json ) ).

    DO.
      IF lv_count > 20.
        EXIT. " todo
      ENDIF.
      lv_count = lv_count + 1.

      li_node = li_reader->read_next_node( ).
      IF li_node IS INITIAL.
        EXIT.
      ENDIF.

      CASE li_node->type.
        WHEN if_sxml_node=>co_nt_element_open.
          li_open ?= li_node.
          WRITE: / 'open node, type:', li_open->qname-name.

          lv_push = '/'.
          lt_attributes = li_open->get_attributes( ).
          LOOP AT lt_attributes INTO li_attribute.
            lv_push = li_attribute->get_value( ).
          ENDLOOP.
          lo_stack->push( lv_push ).

          WRITE / lo_stack->get( ).
        WHEN if_sxml_node=>co_nt_element_close.
          li_close ?= li_node.
          lo_stack->pop( ).

        WHEN if_sxml_node=>co_nt_value.
          li_value ?= li_node.
          WRITE: / lo_stack->get( ), 'value:', li_value->get_value( ).

      ENDCASE.

    ENDDO.

  ENDMETHOD.
ENDCLASS.