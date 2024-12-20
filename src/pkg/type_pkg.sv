package type_pkg;

typedef struct packed {
  int id;
  logic [31:0] data1;
  logic [31:0] data2;
  logic [31:0] data3;
  logic [31:0] data4;
  logic valid;
} que_type_t;

endpackage