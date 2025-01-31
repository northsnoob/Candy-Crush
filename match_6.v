
module match_row_3(
    input [2:0] left_block,center_block,right_block,
    output match_out
);
parameter color_Empty  = 3'b111;
wire valid,c0,c1;
assign c0 = (left_block==center_block)? 1'b1 : 1'b0;
assign c1 = (left_block==right_block) ? 1'b1 : 1'b0;
assign valid = ~(color_Empty==left_block);
assign match_out = (c0 & c1 & valid)? 1'b1:1'b0;
endmodule

module match_6(
    input [2:0] block_in_0,block_in_1,block_in_2, // left is 0 , right is 5
                block_in_3,block_in_4,block_in_5,
    output [3:0] match_out
);
match_row_3 my_match_row_3_0(
    .left_block(block_in_0),
    .center_block(block_in_1),
    .right_block(block_in_2),
    .match_out(match_out[0])
);
match_row_3 my_match_row_3_1(
    .left_block(block_in_1),
    .center_block(block_in_2),
    .right_block(block_in_3),
    .match_out(match_out[1])
);
match_row_3 my_match_row_3_2(
    .left_block(block_in_2),
    .center_block(block_in_3),
    .right_block(block_in_4),
    .match_out(match_out[2])
);
match_row_3 my_match_row_3_3(
    .left_block(block_in_3),
    .center_block(block_in_4),
    .right_block(block_in_5),
    .match_out(match_out[3])
);
endmodule

