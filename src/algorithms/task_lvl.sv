import "DPI-C" function real get_current_time();
import type_pkg::*;

module task_lvl;
  
que_type_t que0 [$];
que_type_t que1 [$];
que_type_t que2 [$];
que_type_t que3 [$];

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

task task_00 (
  input int id_i,
  output int found_que_idx_o,
  output bit found_flag_o
);
  que_seach(id_i, que0, found_que_idx_o, found_flag_o);
endtask

task task_01 (
  input int id_i,
  output int found_que_idx_o,
  output bit found_flag_o
);
  que_seach(id_i, que1, found_que_idx_o, found_flag_o);
endtask


task task_02(
  input int id_i,
  output int found_que_idx_o,
  output bit found_flag_o
);
  que_seach(id_i, que2, found_que_idx_o, found_flag_o);
endtask

task task_03(
  input int id_i,
  output int found_que_idx_o,
  output bit found_flag_o
);
  que_seach(id_i, que3, found_que_idx_o, found_flag_o);
endtask

endmodule