`timescale 10ns/1ns
`include "CC.v"
module tb_CC(
    
);
parameter PERIOD  = 10;
reg clk,rst_n;
reg in_valid_1,in_valid_2;
wire [1:0] in_action;
wire [2:0] in_color;
wire [5:0] in_starting_pos;
wire in_stripe;
wire out_valid;
wire [6:0] out_score;
CC uut_CC(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid_1(in_valid_1),
    .in_valid_2(in_valid_2),
    .in_action(in_action),
    .in_color(in_color),
    .in_starting_pos(in_starting_pos),
    .in_stripe(in_stripe),
    .out_score(out_score),
    .out_valid(out_valid)
);
always
   #(PERIOD/2) clk=~clk;
initial begin
    force clk = 0;
    rst_n = 0;
    #(PERIOD/2) rst_n = 1;
    #(PERIOD/2) release clk;
end
task YOU_PASS_task; begin
    $display ("--------------------------------------------------------------------");
    $display ("                         Congratulations!                           ");
    $display ("                  You have passed all patterns!                     ");
    $display ("--------------------------------------------------------------------");
end endtask
parameter SAMPLE_N = 5;
parameter PATTERN_BITS = 223;
reg [PATTERN_BITS-1:0] pattern_file [0:SAMPLE_N-1];
reg [PATTERN_BITS-1:0] pattern;
reg [2:0] gt_in_color;
reg [5:0] gt_in_starting_pos;
reg [1:0] gt_in_action;
reg gt_in_stripe;
wire [6:0] gt_out_score;
reg [6:0] ans_out_score;
integer first_four_cycle = 0;
reg timing_eligible;

parameter pat_in_color_max = PATTERN_BITS-1;
parameter pat_in_stripe_row_max = pat_in_color_max - 108;
parameter pat_in_stripe_col_max = pat_in_stripe_row_max - 12;
parameter pat_in_stripe_type_max = pat_in_stripe_col_max - 12;
parameter pat_in_action_row_max = pat_in_stripe_type_max - 4;
parameter pat_in_action_col_max = pat_in_action_row_max - 30;
parameter pat_in_action_max = pat_in_action_col_max - 30;
parameter pat_out_score_max = pat_in_action_max - 20;
integer i;
task set_candy;begin
    // integer i;
    first_four_cycle = 0;
    @(negedge clk);
    for(i=0;i<36;i=i+1)begin
        in_valid_1 = 1;
        // gt_in_color = pattern[(pat_in_color_max)-i*3:(pat_in_color_max)-i*3-2];
        // gt_in_starting_pos = {pattern[pat_in_stripe_row_max-first_four_cycle*3:pat_in_stripe_row_max-first_four_cycle*3-2],
        //                       pattern[pat_in_stripe_col_max-first_four_cycle*3:pat_in_stripe_col_max-first_four_cycle*3-2]};
        gt_in_stripe = pattern[pat_in_stripe_type_max-first_four_cycle];
        gt_in_color[2] =  pattern[(pat_in_color_max)-i*3];
        gt_in_color[1] =  pattern[(pat_in_color_max)-i*3-1];
        gt_in_color[0] =  pattern[(pat_in_color_max)-i*3-2];
        gt_in_starting_pos[5] = pattern[pat_in_stripe_row_max-first_four_cycle*3];
        gt_in_starting_pos[4] = pattern[pat_in_stripe_row_max-first_four_cycle*3-1];
        gt_in_starting_pos[3] = pattern[pat_in_stripe_row_max-first_four_cycle*3-2];
        gt_in_starting_pos[2] = pattern[pat_in_stripe_col_max-first_four_cycle*3];
        gt_in_starting_pos[1] = pattern[pat_in_stripe_col_max-first_four_cycle*3-1];
        gt_in_starting_pos[0] = pattern[pat_in_stripe_col_max-first_four_cycle*3-2];
        @(negedge clk);
        first_four_cycle = first_four_cycle + 1;
    end
    // @(negedge clk);
    in_valid_1 = 0;
    @(negedge clk);
end
endtask
task set_action;begin
    // integer i;
    @(negedge clk);
    for(i=0;i<10;i=i+1)begin
        in_valid_2 = 1;
        // gt_in_starting_pos= {pattern[pat_in_action_row_max-i*3:pat_in_action_row_max-i*3-2],
        //                      pattern[pat_in_action_col_max-i*3:pat_in_action_col_max-i*3-2]};
        // gt_in_action = pattern[pat_in_action_max-i*2:pat_in_action_max-1-i*2];
        gt_in_starting_pos[5] = pattern[pat_in_action_row_max-i*3];
        gt_in_starting_pos[4] = pattern[pat_in_action_row_max-i*3-1];
        gt_in_starting_pos[3] = pattern[pat_in_action_row_max-i*3-2];
        gt_in_starting_pos[2] = pattern[pat_in_action_col_max-i*3];
        gt_in_starting_pos[1] = pattern[pat_in_action_col_max-i*3-1];
        gt_in_starting_pos[0] = pattern[pat_in_action_col_max-i*3-2];
        gt_in_action[1] =  pattern[pat_in_action_max-i*2];
        gt_in_action[0] =  pattern[pat_in_action_max-i*2-1];
        @(negedge clk);
        
    end 
    in_valid_2 = 0;
    ans_out_score = pattern[pat_out_score_max:pat_out_score_max-6];
    @(negedge clk);
end
endtask
assign in_color = (in_valid_1)? gt_in_color:3'dx;
assign in_starting_pos = ((in_valid_1&&first_four_cycle<4)|in_valid_2)? gt_in_starting_pos:6'dx;
assign in_action = (in_valid_2)? gt_in_action:2'dx;
assign in_stripe = (in_valid_1&&first_four_cycle<4)? gt_in_stripe:1'dx;
reg [9:0] timing_count;
always@(negedge clk)begin
    if(in_valid_2||out_valid) timing_count <= 0;
    else timing_count <= timing_count+1;
end
assign gt_out_score = (out_valid)? ans_out_score:7'd0;
// wire score_correct = (gt_out_score===out_score);
reg score_correct;
// reg [2:0] fail_count;
reg fail_id [3:7];
integer  k,u;
reg [9:0] success;
initial begin
    $readmemb("./Pattern.dat", pattern_file);
    in_valid_2 = 0;
    in_valid_1 = 0;
    score_correct = 1;
    success = 0;
    fail_id[3] = 0;
    wait(rst_n==0);
    wait(rst_n==1);
    fail_id[4] = 0;
    fail_id[5] = 0;
    fail_id[6] = 0;
    fail_id[7] = 0;
    for (u=0; u < SAMPLE_N; u = u + 1) begin
        pattern = pattern_file[u];
        set_candy();
        // @(negedge clk);
        // @(negedge clk);
        set_action();
        wait(out_valid);
        #(0.05) score_correct = (ans_out_score===out_score);
        // for (k=0;k<1000;k=k+1)begin
        //     @(negedge clk);
        //     if(out_valid)
        //         k=1000;
        // end
        if(score_correct)
            success = success+1;
        repeat(3) @(negedge clk);
        
    end
    $display("    Success %3d/%3d  ",success,SAMPLE_N);
    // $display("******************************************************");
    // for(i=3; i<=7;i=i+1)
    //     if(fail_id[i])
    //         $display("*                  SPEC %d IS FAIL                   *",i);
    // $display("******************************************************");
    YOU_PASS_task();
    #(PERIOD*10) $finish;
end
always@(posedge rst_n)
    if(out_valid!=0||out_score!=0)begin
        // fail_id[3] <= 1'b1;
        $display("*************************************************************************");
        $display("*                  SPEC 3 IS FAIL                    ");
        $display("*   out_valid & out_score shoulde be 0 after initial RESET at t=%8t.  ",$time);
        $display("*************************************************************************");
        #30 $finish;
    end
reg one_clk;
initial one_clk=0;
always@(negedge clk)
    if(out_valid)begin
        if (one_clk)begin
            fail_id[4] <= 1'b1;
            $display("*************************************************************************");
            $display("*                  SPEC 4 IS FAIL                    ");
            $display("*   out_valid high is more than 1 cycle at t=%8t.  ",$time);
            $display("*************************************************************************");
            #30 $finish;
        end
        one_clk <= 1;
    end
    else
        one_clk <= 0;
always@(negedge clk)
    if(timing_count>=500)begin
        // fail_id[5] <= 1'b1;
        $display("*************************************************************************");
        $display("*                  SPEC 5 IS FAIL                    ");
        $display("*   The execution latency are over 500 cycles at t=%8t.  ",$time);
        $display("*************************************************************************");
        #30 $finish;
    end
// always@(negedge score_correct)
initial 
    @(negedge score_correct);
    // fail_id[6] <= 1'b1;
    $display("*************************************************************************");
    $display("*                  SPEC 6 IS FAIL                    ");
    $display("*   out_score shoulde be correct after out_valid is high at t=%8t.  ",$time);
    $display("*************************************************************************");
    #30 $finish;

always@(negedge out_valid)begin
// initial begin
    // @(negedge out_valid);
    if(out_score===0) begin
        // fail_id[7] <= 1'b1;
        $display("*************************************************************************");
        $display("*                  SPEC 7 IS FAIL                    ");
        $display("*   out_score shoulde be 0 after out_valid is pulled down at t=%8t.  ",$time);
        $display("*************************************************************************");
        #30 $finish;
    end
end
endmodule
