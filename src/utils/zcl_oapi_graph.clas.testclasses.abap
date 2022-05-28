CLASS ltcl_graph DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_graph IMPLEMENTATION.
  METHOD test.
    DATA lo_graph TYPE REF TO zcl_oapi_graph.
    CREATE OBJECT lo_graph.
    lo_graph->add_vertex( |foo| ).
    lo_graph->add_vertex( |bar| ).
    lo_graph->add_edge(
      iv_from = |foo|
      iv_to   = |bar| ).
  ENDMETHOD.
ENDCLASS.