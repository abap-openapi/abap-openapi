CLASS zcl_oapi_graph DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_edge,
             from TYPE string,
             to  TYPE string,
           END OF ty_edge.
    METHODS add_vertex IMPORTING iv_vertex TYPE string.
    METHODS add_edge
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string.
  PRIVATE SECTION.
    DATA mt_vertices TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA mt_edges TYPE STANDARD TABLE OF ty_edge WITH DEFAULT KEY.
ENDCLASS.

CLASS zcl_oapi_graph IMPLEMENTATION.
  METHOD add_vertex.
    READ TABLE mt_vertices WITH KEY table_line = iv_vertex TRANSPORTING NO FIELDS.
    ASSERT sy-subrc <> 0.
    APPEND iv_vertex TO mt_vertices.
  ENDMETHOD.

  METHOD add_edge.
    DATA ls_edge TYPE ty_edge.
    ASSERT iv_from IS NOT INITIAL.
    ASSERT iv_to IS NOT INITIAL.
    READ TABLE mt_edges WITH KEY from = iv_from to = iv_to TRANSPORTING NO FIELDS.
    ASSERT sy-subrc <> 0.
    ls_edge-from = iv_from.
    ls_edge-to = iv_to.
    INSERT ls_edge INTO TABLE mt_edges.
  ENDMETHOD.
ENDCLASS.