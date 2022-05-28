CLASS zcl_oapi_graph DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_edge,
             from TYPE string,
             to  TYPE string,
           END OF ty_edge.
    METHODS add_vertex IMPORTING iv_vertex TYPE string.
    METHODS add_edge IMPORTING is_edge TYPE ty_edge.
  PRIVATE SECTION.
    DATA mt_vertices TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA mt_edges TYPE STANDARD TABLE OF ty_edge WITH DEFAULT KEY.
ENDCLASS.

CLASS zcl_oapi_graph IMPLEMENTATION.
  METHOD add_vertex.
    READ TABLE mt_vertices WITH KEY table_line = iv_vertex TRANSPORTING NO FIELDS.
    ASSERT sy-subrc = 0.
    APPEND iv_vertex TO mt_vertices.
  ENDMETHOD.

  METHOD add_edge.
    READ TABLE mt_edges WITH KEY table_line = is_edge TRANSPORTING NO FIELDS.
    ASSERT sy-subrc = 0.
    INSERT is_edge INTO TABLE mt_edges.
  ENDMETHOD.
ENDCLASS.