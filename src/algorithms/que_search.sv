import "DPI-C" function real get_current_time();
import type_pkg::*;

module que_search;
  que_type_t que [$];

  task automatic fill_que (
    ref que_type_t queue [$],
    input int iteration
  );
    que_type_t que_buff;

    $display("THE LINE IN 22");
    for (int itr = 0; itr < iteration; itr = itr + 1) begin
      que_buff.id = itr;
      que_buff.data1 = 32'($urandom);
      que_buff.data2 = 32'($urandom);
      que_buff.data3 = 32'($urandom % 5001);
      que_buff.data4 = 32'($urandom % 5001);
      que_buff.valid = 1'b1;
      
      queue.push_back(que_buff);
    end
  endtask

  task que_seach_parallel(
    input int id_i,
    input int child_process_num_i, // it should be two and two's powers
    // ref que_type_t queue_i [$],
    input que_type_t queue_i [$],
    output int found_que_idx_o,
    output bit found_flag_o
  );

    automatic int queue_size = queue_i.size();
    automatic int local_que_size = queue_size >> $clog2(child_process_num_i);
    automatic int found_que_idx = 0;
    automatic bit found_flag = 0;

    // automatic que_type_t local_queue [$] = queue_i;
    $display("We are in parallel queue");
    fork begin
      for (int cp_id = 0; cp_id < child_process_num_i; cp_id++) begin
        fork
          automatic int local_cp_idx = cp_id;
          automatic int local_start = local_que_size * local_cp_idx;
          automatic int local_finish = (local_cp_idx != (child_process_num_i - 1)) ? local_que_size * local_cp_idx + local_que_size : queue_size;
          begin
            // #2  $display(" [TEST] CHILD PROCESS ID: %0d  |  LOOKING QUE ID: %0d  |  TIME: %0t", local_cp_idx, '0, $time); // to debug process
            for (int i = local_start; i < local_finish; i++) begin
              if (found_flag == '1) break;
              // if (id_i < local_start || id_i > (local_finish-1)) break;
              if (queue_i[i].id == id_i) begin
                found_que_idx = i; // just one process access there
                found_flag = 1;
                break;
              end
            end
          end
        join_none
      end
    end
    join_any
    wait fork;

    found_flag_o = found_flag;
    found_que_idx_o = found_que_idx;
  endtask

  task automatic que_seach(
    input int id_i,
    ref que_type_t queue_i [$],
    output int found_que_idx_o,
    output bit found_flag_o
  );
    automatic int found_que_idx;
    automatic bit found_flag = 0;

    automatic que_type_t local_queue [$] = queue_i;

    for (int i = 0; i < local_queue.size(); i++) begin
      if (id_i == local_queue[i].id) begin
        found_flag = 1;
        found_que_idx = i;
        break;
      end
    end

    found_flag_o = found_flag;
    found_que_idx_o = found_que_idx;

  endtask

  real start_time, end_time, elapsed_time [2];

  int found_id_parallel, found_id_serial;
  bit found_flag_parallel, found_flag_serial;

  int process_num;
  int search_id;
  int queue_element_num;

  initial begin
    process_num = 8;
    search_id = 950000;
    queue_element_num = 1000000;

    fill_que(que, queue_element_num);
    start_time = get_current_time();
    que_seach(search_id, que, found_id_serial, found_flag_serial);
    end_time = get_current_time();

    elapsed_time[0] = end_time - start_time; // calculate elapsed time
    
    $display("Entering to parallel system");
    start_time = get_current_time();
    que_seach_parallel(search_id, process_num, que, found_id_parallel, found_flag_parallel);
    end_time = get_current_time();

    elapsed_time[1] = end_time - start_time; // calculate elapsed time

    $display("\n---> Queue size: %0d  |  The id that will be seached: %0d", queue_element_num, search_id);
    $display("\n---> Elapsed time for serial: %e seconds  |  The id found: %0d", elapsed_time[0], found_id_serial);
    $display("\n---> Elapsed time for parallel: %e seconds  |  The id found: %0d  |  Process num: %0d", elapsed_time[1], found_id_parallel, process_num);
    $display("\n");

    #10;
    $finish;
  end

endmodule