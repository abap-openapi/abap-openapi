CLASS lcl_stack DEFINITION.
  PUBLIC SECTION.
    METHODS push
      IMPORTING
        iv_name TYPE string
        iv_type TYPE string.
    METHODS pop RETURNING VALUE(rv_name) TYPE string.
    METHODS is_array RETURNING VALUE(rv_array) TYPE abap_bool.
    METHODS get_and_increase_index RETURNING VALUE(rv_index) TYPE string.
    METHODS get_full_name RETURNING VALUE(rv_path) TYPE string.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_data,
             name        TYPE string,
             is_array    TYPE abap_bool,
             array_index TYPE i,
           END OF ty_data.
    DATA mt_data TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY.
ENDCLASS.

CLASS lcl_stack IMPLEMENTATION.
  METHOD push.
    DATA ls_data LIKE LINE OF mt_data.
    ls_data-name = iv_name.
    ls_data-is_array = boolc( iv_type = 'array').
    APPEND ls_data TO mt_data.
  ENDMETHOD.

  METHOD is_array.
    DATA lv_index TYPE i.
    DATA ls_data LIKE LINE OF mt_data.
    lv_index = lines( mt_data ).
    READ TABLE mt_data INTO ls_data INDEX lv_index.       "#EC CI_SUBRC
    rv_array = ls_data-is_array.
  ENDMETHOD.

  METHOD get_and_increase_index.
    DATA lv_index TYPE i.
    FIELD-SYMBOLS <ls_data> LIKE LINE OF mt_data.

    lv_index = lines( mt_data ).
    READ TABLE mt_data ASSIGNING <ls_data> INDEX lv_index.
    IF sy-subrc = 0.
      <ls_data>-array_index = <ls_data>-array_index + 1.
      rv_index = <ls_data>-array_index.
      rv_index = condense( rv_index ).
    ENDIF.
  ENDMETHOD.

  METHOD pop.
    DATA lv_index TYPE i.
    DATA ls_data LIKE LINE OF mt_data.
    lv_index = lines( mt_data ).
    IF lv_index > 0.
      READ TABLE mt_data INTO ls_data INDEX lv_index.     "#EC CI_SUBRC
      rv_name = ls_data-name.
      DELETE mt_data INDEX lv_index.
    ENDIF.
  ENDMETHOD.

  METHOD get_full_name.
    DATA ls_data LIKE LINE OF mt_data.
    LOOP AT mt_data INTO ls_data.
      rv_path = rv_path && ls_data-name.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_parser DEFINITION.
  PUBLIC SECTION.
    METHODS parse
      IMPORTING iv_json        TYPE string
      RETURNING VALUE(rt_data) TYPE ty_data_tt.
ENDCLASS.

CLASS lcl_parser IMPLEMENTATION.
  METHOD parse.

    DATA li_node TYPE REF TO if_sxml_node.
    DATA li_next TYPE REF TO if_sxml_node.
    DATA li_reader TYPE REF TO if_sxml_reader.
    DATA li_close TYPE REF TO if_sxml_close_element.
    DATA li_open TYPE REF TO if_sxml_open_element.
    DATA lt_attributes TYPE if_sxml_attribute=>attributes.
    DATA li_attribute TYPE REF TO if_sxml_attribute.
    DATA li_value TYPE REF TO if_sxml_value_node.
    DATA lv_push TYPE string.
    DATA lv_name TYPE string.
    DATA lo_stack TYPE REF TO lcl_stack.
    DATA ls_data LIKE LINE OF rt_data.
    DATA lv_index TYPE i.
    DATA lt_nodes TYPE STANDARD TABLE OF REF TO if_sxml_node WITH DEFAULT KEY.

*    FIELD-SYMBOLS <ls_data> LIKE LINE OF rt_data.

    CREATE OBJECT lo_stack.

    li_reader = cl_sxml_string_reader=>create( cl_abap_codepage=>convert_to( iv_json ) ).
*    WRITE '@KERNEL console.dir("parsing done");'.

    DO.
      li_node = li_reader->read_next_node( ).
      IF li_node IS INITIAL.
        EXIT.
      ENDIF.
      APPEND li_node TO lt_nodes.
    ENDDO.

*    WRITE '@KERNEL console.dir(lt_nodes.array().length + " nodes");'.

    LOOP AT lt_nodes INTO li_node.
      lv_index = sy-tabix.

      CASE li_node->type.
        WHEN if_sxml_node=>co_nt_element_open.
          li_open ?= li_node.
*          WRITE: / 'open node, type:', li_open->qname-name.

          lt_attributes = li_open->get_attributes( ).
*          WRITE '@KERNEL console.dir(lt_attributes.array().length);'.
          READ TABLE lt_attributes INDEX 1 INTO li_attribute.
          IF sy-subrc = 0.
            lv_push = li_attribute->get_value( ).
          ELSEIF lo_stack->is_array( ) = abap_true.
            lv_push = lo_stack->get_and_increase_index( ).
          ENDIF.

          IF lv_push IS NOT INITIAL.

            CLEAR ls_data.
            ls_data-parent = lo_stack->get_full_name( ).
            ls_data-name = lv_push.
            ls_data-full_name = ls_data-parent && ls_data-name.

            lv_index = lv_index + 1.
            READ TABLE lt_nodes INDEX lv_index INTO li_next.
            IF sy-subrc = 0 AND li_next->type = if_sxml_node=>co_nt_value.
              li_value ?= li_next.
              ls_data-value = li_value->get_value( ).
            ENDIF.

            APPEND ls_data TO rt_data.

            lo_stack->push(
              iv_name = lv_push
              iv_type = li_open->qname-name ).
          ENDIF.

          IF li_open->qname-name = 'object' OR li_open->qname-name = 'array'.
            CLEAR ls_data.
            ls_data-parent = lo_stack->get_full_name( ).
            ls_data-name = '/'.
            ls_data-full_name = ls_data-parent && ls_data-name.
            APPEND ls_data TO rt_data.

            lo_stack->push(
              iv_name = '/'
              iv_type = li_open->qname-name ).
          ENDIF.

        WHEN if_sxml_node=>co_nt_element_close.
          li_close ?= li_node.
          lv_name = lo_stack->pop( ).
          IF lv_name = '/'.
            lo_stack->pop( ).
          ENDIF.

*        WHEN if_sxml_node=>co_nt_value.
*          li_value ?= li_node.
*          lv_name = lo_stack->get_full_name( ).
* todo, this can be optimized by peeking at the next node when adding to rt_data ?
*          READ TABLE rt_data ASSIGNING <ls_data> WITH KEY full_name = lv_name.
*          IF sy-subrc = 0.
*            <ls_data>-value = li_value->get_value( ).
*          ENDIF.

      ENDCASE.
    ENDLOOP.

*    WRITE '@KERNEL console.dir(rt_data.array().length);'.

    " LOOP AT rt_data INTO ls_data.
    "   WRITE: / 'PARENT: ', ls_data-parent.
    "   WRITE: / 'name: ', ls_data-name.
    "   WRITE: / 'full_name: ', ls_data-full_name.
    "   WRITE: / 'value: ', ls_data-value.
    " ENDLOOP.

  ENDMETHOD.
ENDCLASS.
