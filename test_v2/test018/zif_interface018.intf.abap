INTERFACE zif_interface018 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: Swagger Petstore - OpenAPI 3.0
* Version: 1.0.11

  CONSTANTS base_path TYPE string VALUE ''.

* Operation
  TYPES: BEGIN OF operation,
           operation TYPE i,
         END OF operation.
* Dog
  TYPES: BEGIN OF dog,
           bark TYPE abap_bool,
           breed TYPE string,
         END OF dog.
* body_create_dog
  TYPES: BEGIN OF body_create_dog,
           detail TYPE dog,
           operations TYPE STANDARD TABLE OF operation WITH DEFAULT KEY,
         END OF body_create_dog.

  METHODS _create_dog
    IMPORTING
      body TYPE body_create_dog
    RAISING
      cx_static_check.
ENDINTERFACE.
