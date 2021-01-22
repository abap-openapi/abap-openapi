*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

TYPES: BEGIN OF ty_data,
         parent    TYPE string,
         name      TYPE string,
         full_name TYPE string,
         value     TYPE string,
       END OF ty_data.

TYPES ty_data_tt TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY.
