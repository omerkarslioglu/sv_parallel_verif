
import "DPI-C" function real get_current_time();

module matrix_mul ();

parameter MATRIX_SIZE = 10;

logic signed [31:0] matrix_a [MATRIX_SIZE][MATRIX_SIZE];
logic signed [31:0] matrix_b [MATRIX_SIZE][MATRIX_SIZE];
logic signed [31:0] result [MATRIX_SIZE][MATRIX_SIZE];

/* Coeff. for test */
localparam logic signed [31:0] matrix_1 [MATRIX_SIZE][MATRIX_SIZE] = '{
  '{ 1,  2},
  '{ 3,  4}
};

/* Coeff. for test */
localparam logic signed [31:0] matrix_2 [MATRIX_SIZE][MATRIX_SIZE] = '{
  '{ 2,  0},
  '{ 1,  2}
};

/*
1 2   x  2 0
3 4      1 2

Ans:
4  4
10 8
*/

/* Serial matrix multiplication */
task automatic matrix_mul_serial();
  for (int i = 0; i < MATRIX_SIZE; i++) begin
    for (int j = 0; j < MATRIX_SIZE; j++) begin
      automatic int row = i;
      automatic int col = j;
      result[row][col] = compute_cell(matrix_a, matrix_b, row, col);
    end
  end
endtask

// Thread num = matrix_size / BLCOK_SIZE
localparam BLCOK_SIZE = 20;
int cnt =0;
/* Serial matrix multiplication */
task automatic matrix_mul_parallel();
  //fork
    for (int i = 0; i < MATRIX_SIZE; i += BLCOK_SIZE) begin
      for (int j = 0; j < MATRIX_SIZE; j += BLCOK_SIZE) begin
        fork
          //cnt = cnt + 1;
          //$display("--- cnt --- %0d", cnt);
          automatic int row_start = i;
          automatic int col_start = j;
          for (int row = row_start; row < row_start + BLCOK_SIZE && row < MATRIX_SIZE; row++) begin
            for (int col = col_start; col < col_start + BLCOK_SIZE && col < MATRIX_SIZE; col++) begin
              automatic int r = row;
              automatic int c = col;
              automatic logic signed [31:0] cp_matrix_1 [MATRIX_SIZE][MATRIX_SIZE];
              automatic logic signed [31:0] cp_matrix_2 [MATRIX_SIZE][MATRIX_SIZE];

              cp_matrix_1 = matrix_a;
              cp_matrix_2 = matrix_b;

              result[r][c] = compute_cell(cp_matrix_1, cp_matrix_2, r, c);
            end
          end
        join
      end
    end
  //join
endtask

/* Parallel (semaphore) execution */
task automatic matrix_mul_sem();
  semaphore sem = new(MATRIX_SIZE); // semaphore definition
  // Paralel execution:
  fork
    for (int i = 0; i < MATRIX_SIZE; i++) begin
      begin
        for (int j = 0; j < MATRIX_SIZE; j++) begin
          automatic int row = i;
          automatic int col = j;
          // seperate thread for each cell
            automatic logic [31:0] computed_one_cell;
            computed_one_cell = compute_cell(matrix_a, matrix_b, row, col);
            sem.get(1);
            result[row][col] = computed_one_cell; // critical section
            sem.put(1);
        end
      end
    end
  join
endtask

/* Execution for just one cell */
function automatic logic [31:0] compute_cell(
  ref logic signed [31:0] matrix1 [MATRIX_SIZE][MATRIX_SIZE],
  ref logic signed [31:0] matrix2 [MATRIX_SIZE][MATRIX_SIZE],
  input int row,
  input int col
);
  logic [31:0] cell_result = 0;
  for (int k = 0; k < MATRIX_SIZE; k++) begin
      cell_result += matrix_a[row][k] * matrix_b[k][col]; // Martrix calculation
  end
  return cell_result;
endfunction

/* Execution for just one cell */
function automatic logic [31:0] compute_cell_with_vector(
  ref logic signed [31:0] vector_1 [MATRIX_SIZE],
  ref logic signed [31:0] vector_2 [MATRIX_SIZE]
);
  logic [31:0] cell_result = 0;
  for (int k = 0; k < MATRIX_SIZE; k++) begin
      cell_result += vector_1[k] * vector_2[k];
  end
  return cell_result;
endfunction

/* Prtint matrix */
function automatic void print_matrix(
    ref logic signed [31:0] matrix [MATRIX_SIZE][MATRIX_SIZE]
);
  automatic int row_buff;
  foreach (matrix[row, col]) begin
    if (row_buff != row) $write("\n");
    row_buff = row;
    $write("%6d ", matrix[row][col]);
  end
  $write("\n");
endfunction

/* Fill matrix with random variables */
function automatic void fill_matrix(
    ref logic signed [31:0] matrix [MATRIX_SIZE][MATRIX_SIZE]
);
  automatic int row_buff;
  foreach (matrix[row, col]) begin
    matrix[row][col] = $urandom_range(0, 100);
  end
endfunction

real start_time, end_time, elapsed_time;

initial begin
`ifdef TEST
  matrix_a = matrix_1;
  matrix_b = matrix_2;
`endif

  fill_matrix(matrix_a);
  fill_matrix(matrix_b);

  start_time = get_current_time();
  // matrix_mul_sem();
  //matrix_mul_serial();
  matrix_mul_parallel();
  // matrix_mul_thread_safe(matrix_a, matrix_b, result);
  end_time = get_current_time();

  elapsed_time = end_time - start_time; // calculate elapsed time
  
  $display("Input matrix-1");
  print_matrix(matrix_a);

  $display("Input matrix-2");
  print_matrix(matrix_b);

  $display("Output matrix-result");
  print_matrix(result);

  $display("\n-----> Elapsed time: %e seconds\n", elapsed_time);
  $finish;
end


task automatic matrix_mul_thread_safe(
  input logic signed [31:0] input_matrix_a [MATRIX_SIZE][MATRIX_SIZE],
  input logic signed [31:0] input_matrix_b [MATRIX_SIZE][MATRIX_SIZE],
  output logic signed [31:0] output_result [MATRIX_SIZE][MATRIX_SIZE]
);
  semaphore sema = new(1);
  
  // Her bir matris hücresi için ayrı bir fork oluşturulur
  fork
    for (int i = 0; i < MATRIX_SIZE; i++) begin
      for (int j = 0; j < MATRIX_SIZE; j++) begin
        automatic int row = i;
        automatic int col = j;
        
        fork
          begin
            // Geçici local matris kopyaları oluştur
            logic signed [31:0] local_matrix_a [MATRIX_SIZE][MATRIX_SIZE];
            logic signed [31:0] local_matrix_b [MATRIX_SIZE][MATRIX_SIZE];
            logic signed [31:0] local_cell_result;

            local_matrix_a = input_matrix_a;
            local_matrix_b = input_matrix_b;
            
            local_cell_result = 0;
            for (int k = 0; k < MATRIX_SIZE; k++) begin
              local_cell_result += local_matrix_a[row][k] * local_matrix_b[k][col];
            end

            sema.get();
            output_result[row][col] = local_cell_result;
            sema.put();
          end
        join_none
      end
    end
  join

  wait fork;
endtask

// Thread-safe compute_cell fonksiyonu
function automatic logic [31:0] compute_cell_thread_safe(
  input logic signed [31:0] matrix1 [MATRIX_SIZE][MATRIX_SIZE],
  input logic signed [31:0] matrix2 [MATRIX_SIZE][MATRIX_SIZE],
  input int row,
  input int col
);
  logic [31:0] cell_result = 0;
  for (int k = 0; k < MATRIX_SIZE; k++) begin
      cell_result += matrix1[row][k] * matrix2[k][col]; // Matris çarpımı
  end
  return cell_result;
endfunction

endmodule