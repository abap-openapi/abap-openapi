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

          lt_attributes = li_open->get_attributes( ).
          LOOP AT lt_attributes INTO li_attribute.
            WRITE: / 'key:', li_attribute->get_value( ).
          ENDLOOP.

        WHEN if_sxml_node=>co_nt_element_close.
          li_close ?= li_node.

        WHEN if_sxml_node=>co_nt_value.
          li_value ?= li_node.
          WRITE: / 'value node, value:', li_value->get_value( ).
      ENDCASE.

    ENDDO.

  ENDMETHOD.
ENDCLASS.