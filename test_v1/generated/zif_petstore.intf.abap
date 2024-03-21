INTERFACE zif_petstore PUBLIC.
* Generated by abap-openapi-client
* Swagger Petstore - OpenAPI 3.0, 1.0.19

* Component schema: response_getinventory, object
  TYPES: BEGIN OF response_getinventory,
           dummy_workaround TYPE i,
         END OF response_getinventory.

* Component schema: Tag, object
  TYPES: BEGIN OF tag,
           id TYPE i,
           name TYPE string,
         END OF tag.

* Component schema: Category, object
  TYPES: BEGIN OF category,
           id TYPE i,
           name TYPE string,
         END OF category.

* Component schema: Pet, object
  TYPES: BEGIN OF pet,
           id TYPE i,
           name TYPE string,
           category TYPE category,
           photourls TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           tags TYPE STANDARD TABLE OF tag WITH DEFAULT KEY,
           status TYPE string,
         END OF pet.

* Component schema: response_findpetsbytags, array
  TYPES response_findpetsbytags TYPE STANDARD TABLE OF pet WITH DEFAULT KEY.

* Component schema: response_findpetsbystatus, array
  TYPES response_findpetsbystatus TYPE STANDARD TABLE OF pet WITH DEFAULT KEY.

* Component schema: User, object
  TYPES: BEGIN OF user,
           id TYPE i,
           username TYPE string,
           firstname TYPE string,
           lastname TYPE string,
           email TYPE string,
           password TYPE string,
           phone TYPE string,
           userstatus TYPE i,
         END OF user.

* Component schema: bodycreateuserswithlistinput, array
  TYPES bodycreateuserswithlistinput TYPE STANDARD TABLE OF user WITH DEFAULT KEY.

* Component schema: ApiResponse, object
  TYPES: BEGIN OF apiresponse,
           code TYPE i,
           type TYPE string,
           message TYPE string,
         END OF apiresponse.

* Component schema: Address, object
  TYPES: BEGIN OF address,
           street TYPE string,
           city TYPE string,
           state TYPE string,
           zip TYPE string,
         END OF address.

* Component schema: Customer, object
  TYPES: BEGIN OF customer,
           id TYPE i,
           username TYPE string,
           address TYPE STANDARD TABLE OF address WITH DEFAULT KEY,
         END OF customer.

* Component schema: Order, object
  TYPES: BEGIN OF order,
           id TYPE i,
           petid TYPE i,
           quantity TYPE i,
           shipdate TYPE string,
           status TYPE string,
           complete TYPE abap_bool,
         END OF order.

* PUT - "Update an existing pet"
* Operation id: updatePet
* Response: 200
*     application/xml, #/components/schemas/Pet
*     application/json, #/components/schemas/Pet
* Response: 400
* Response: 404
* Response: 405
* Body ref: #/components/schemas/Pet
  METHODS updatepet
    IMPORTING
      body TYPE pet
    RETURNING
      VALUE(return_data) TYPE pet
    RAISING cx_static_check.

* POST - "Add a new pet to the store"
* Operation id: addPet
* Response: 200
*     application/xml, #/components/schemas/Pet
*     application/json, #/components/schemas/Pet
* Response: 405
* Body ref: #/components/schemas/Pet
  METHODS addpet
    IMPORTING
      body TYPE pet
    RETURNING
      VALUE(return_data) TYPE pet
    RAISING cx_static_check.

* GET - "Finds Pets by status"
* Operation id: findPetsByStatus
* Parameter: status, optional, query
* Response: 200
*     application/xml, #/components/schemas/response_findpetsbystatus
*     application/json, #/components/schemas/response_findpetsbystatus
* Response: 400
  METHODS findpetsbystatus
    IMPORTING
      status TYPE string DEFAULT 'available'
    RETURNING
      VALUE(return_data) TYPE response_findpetsbystatus
    RAISING cx_static_check.

* GET - "Finds Pets by tags"
* Operation id: findPetsByTags
* Parameter: tags, optional, query
* Response: 200
*     application/xml, #/components/schemas/response_findpetsbytags
*     application/json, #/components/schemas/response_findpetsbytags
* Response: 400
  METHODS findpetsbytags
    IMPORTING
      tags TYPE string OPTIONAL
    RETURNING
      VALUE(return_data) TYPE response_findpetsbytags
    RAISING cx_static_check.

* GET - "Find pet by ID"
* Operation id: getPetById
* Parameter: petId, required, path
* Response: 200
*     application/xml, #/components/schemas/Pet
*     application/json, #/components/schemas/Pet
* Response: 400
* Response: 404
  METHODS getpetbyid
    IMPORTING
      petid TYPE i
    RETURNING
      VALUE(return_data) TYPE pet
    RAISING cx_static_check.

* POST - "Updates a pet in the store with form data"
* Operation id: updatePetWithForm
* Parameter: petId, required, path
* Parameter: name, optional, query
* Parameter: status, optional, query
* Response: 405
  METHODS updatepetwithform
    IMPORTING
      petid TYPE i
      name TYPE string OPTIONAL
      status TYPE string OPTIONAL
    RAISING cx_static_check.

* DELETE - "Deletes a pet"
* Operation id: deletePet
* Parameter: api_key, optional, header
* Parameter: petId, required, path
* Response: 400
  METHODS deletepet
    IMPORTING
      api_key TYPE string OPTIONAL
      petid TYPE i
    RAISING cx_static_check.

* POST - "uploads an image"
* Operation id: uploadFile
* Parameter: petId, required, path
* Parameter: additionalMetadata, optional, query
* Response: 200
*     application/json, #/components/schemas/ApiResponse
  METHODS uploadfile
    IMPORTING
      petid TYPE i
      additionalmetadata TYPE string OPTIONAL
    RETURNING
      VALUE(return_data) TYPE apiresponse
    RAISING cx_static_check.

* GET - "Returns pet inventories by status"
* Operation id: getInventory
* Response: 200
*     application/json, #/components/schemas/response_getinventory
  METHODS getinventory
    RETURNING
      VALUE(return_data) TYPE response_getinventory
    RAISING cx_static_check.

* POST - "Place an order for a pet"
* Operation id: placeOrder
* Response: 200
*     application/json, #/components/schemas/Order
* Response: 405
* Body ref: #/components/schemas/Order
  METHODS placeorder
    IMPORTING
      body TYPE order
    RETURNING
      VALUE(return_data) TYPE order
    RAISING cx_static_check.

* GET - "Find purchase order by ID"
* Operation id: getOrderById
* Parameter: orderId, required, path
* Response: 200
*     application/xml, #/components/schemas/Order
*     application/json, #/components/schemas/Order
* Response: 400
* Response: 404
  METHODS getorderbyid
    IMPORTING
      orderid TYPE i
    RETURNING
      VALUE(return_data) TYPE order
    RAISING cx_static_check.

* DELETE - "Delete purchase order by ID"
* Operation id: deleteOrder
* Parameter: orderId, required, path
* Response: 400
* Response: 404
  METHODS deleteorder
    IMPORTING
      orderid TYPE i
    RAISING cx_static_check.

* POST - "Create user"
* Operation id: createUser
* Response: default
*     application/json, #/components/schemas/User
*     application/xml, #/components/schemas/User
* Body ref: #/components/schemas/User
  METHODS createuser
    IMPORTING
      body TYPE user
    RAISING cx_static_check.

* POST - "Creates list of users with given input array"
* Operation id: createUsersWithListInput
* Response: 200
*     application/xml, #/components/schemas/User
*     application/json, #/components/schemas/User
* Response: default
* Body ref: #/components/schemas/bodycreateuserswithlistinput
  METHODS createuserswithlistinput
    IMPORTING
      body TYPE bodycreateuserswithlistinput
    RETURNING
      VALUE(return_data) TYPE user
    RAISING cx_static_check.

* GET - "Logs user into the system"
* Operation id: loginUser
* Parameter: username, optional, query
* Parameter: password, optional, query
* Response: 200
*     application/xml, string
*     application/json, string
* Response: 400
  METHODS loginuser
    IMPORTING
      username TYPE string OPTIONAL
      password TYPE string OPTIONAL
    RAISING cx_static_check.

* GET - "Logs out current logged in user session"
* Operation id: logoutUser
* Response: default
  METHODS logoutuser
    RAISING cx_static_check.

* GET - "Get user by user name"
* Operation id: getUserByName
* Parameter: username, required, path
* Response: 200
*     application/xml, #/components/schemas/User
*     application/json, #/components/schemas/User
* Response: 400
* Response: 404
  METHODS getuserbyname
    IMPORTING
      username TYPE string
    RETURNING
      VALUE(return_data) TYPE user
    RAISING cx_static_check.

* PUT - "Update user"
* Operation id: updateUser
* Parameter: username, required, path
* Response: default
* Body ref: #/components/schemas/User
  METHODS updateuser
    IMPORTING
      username TYPE string
      body TYPE user
    RAISING cx_static_check.

* DELETE - "Delete user"
* Operation id: deleteUser
* Parameter: username, required, path
* Response: 400
* Response: 404
  METHODS deleteuser
    IMPORTING
      username TYPE string
    RAISING cx_static_check.

ENDINTERFACE.
