/*
 * @info: --> Auto create header by korofileheader <--
 * @Author: Northern NOOB
 * @Mail: northsnoob@gmail.com
 * @Date: 2025-02-01 16:23
 * @LastEditors: Northern NOOB
 * @LastEditTime: 2025-02-12 10:24
 * @Version: default
 */
module CC(
    input clk,rst_n,
    input in_valid_1, in_valid_2, 
          in_stripe, 
    input [2:0] in_color,
    input [1:0] in_action,
    input [5:0] in_starting_pos,
    output reg out_valid,
    output reg [6:0] out_score
          

);
reg [4:0] candy_matrix [0:35];
// parameter color_Red    = 5'b00000,
//           color_Blue   = 5'b00001,
//           color_Green  = 5'b00010,
//           color_Yellow = 5'b00011,
//           color_Orange = 5'b00100,
//           color_Purple = 5'b00101,
//           color_Empty  = 5'b00111;

parameter color_Red    = 3'b000,
          color_Blue   = 3'b001,
          color_Green  = 3'b010,
          color_Yellow = 3'b011,
          color_Orange = 3'b100,
          color_Purple = 3'b101,
          color_Empty  = 3'b111;
          
parameter NOTHING    = 2'b00,
          set_clr    = 2'b01,
          set_pre_dead = 2'b10,
          set_dead   = 2'b11;

parameter action_Up    = 2'b00,
          action_Down  = 2'b01,
          action_Left  = 2'b10,
          action_Right = 2'b11;

parameter stripe_horizontal = 1'b0,
          stripe_vertical   = 1'b1;

parameter state_initiai       = 3'b000,
          state_data_in       = 3'b001,
          state_check_candy   = 3'b010,
          state_check_stripe  = 3'b011,
          state_update_map    = 3'b100,
          state_read_action   = 3'b101,
          state_check_action  = 3'b110,
          state_output        = 3'b111;
wire [5:0] row_d_six;
reg [2:0] row,col;
reg [1:0] action_type [0:9];
reg [2:0] action_pos_row [0:9];
reg [2:0] action_pos_col [0:9];
reg [3:0] set_action_count;
reg [2:0] sys_state,next_state;
reg [6:0] score_tmp;
reg [1:0] candy_matrix_tmp [0:35];
wire [5:0] project_in_p;
parameter col_d_six = 6;
wire [5:0] project_p;
wire [2:0] wire_row,wire_col;
// assign project_in_p = (in_starting_pos[5:3]*6)+in_starting_pos[2:0];
assign project_p = (row_d_six)+wire_col;
assign row_d_six = wire_row*6;
wire [5:0] project_row_p0,project_row_p1,project_row_p2,
           project_row_p3,project_row_p4,project_row_p5,
           project_col_p0,project_col_p1,project_col_p2,
           project_col_p3,project_col_p4,project_col_p5;
assign project_row_p0 = row_d_six;
assign project_row_p1 = row_d_six+1;
assign project_row_p2 = row_d_six+2;
assign project_row_p3 = row_d_six+3;
assign project_row_p4 = row_d_six+4;
assign project_row_p5 = row_d_six+5;
assign project_col_p0 = wire_col;
assign project_col_p1 = wire_col+col_d_six;
assign project_col_p2 = wire_col+{col_d_six,1'b0};
assign project_col_p3 = project_col_p1+{col_d_six,1'b0};
assign project_col_p4 = wire_col+{col_d_six,2'b00};
assign project_col_p5 = project_col_p1+{col_d_six,2'b00};
reg [3:0] action_count;
assign wire_row = (sys_state == state_read_action)? action_pos_row[action_count]:
                  (sys_state[2:1] == 2'b00)?        in_starting_pos[5:3] : row;
assign wire_col = (sys_state == state_read_action)? action_pos_col[action_count]:
                  (sys_state[2:1] == 2'b00)?        in_starting_pos[2:0] : col;
wire [3:0] row_match,col_match;
wire scan_finish;

match_6 my_match_col(
    .block_in_0(candy_matrix[project_col_p0][2:0]),
    .block_in_1(candy_matrix[project_col_p1][2:0]),
    .block_in_2(candy_matrix[project_col_p2][2:0]),
    .block_in_3(candy_matrix[project_col_p3][2:0]),
    .block_in_4(candy_matrix[project_col_p4][2:0]),
    .block_in_5(candy_matrix[project_col_p5][2:0]),
    .match_out(col_match)
);
match_6 my_match_row(
    .block_in_0(candy_matrix[project_row_p0][2:0]),
    .block_in_1(candy_matrix[project_row_p1][2:0]),
    .block_in_2(candy_matrix[project_row_p2][2:0]),
    .block_in_3(candy_matrix[project_row_p3][2:0]),
    .block_in_4(candy_matrix[project_row_p4][2:0]),
    .block_in_5(candy_matrix[project_row_p5][2:0]),
    .match_out(row_match)
);
reg [6:0] set_color_count;

reg [5:0] i;
reg action_run;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        set_color_count <= 0;
        action_count <= 0;
        action_run <= 0;
        for (i=0;i<36;i=i+1)begin
            candy_matrix[i] <= 5'b00000;
        end
    end else begin
        if(in_valid_1 && set_color_count!=36)begin // not must
            candy_matrix [set_color_count][2:0] <= in_color;
            if (set_color_count<4)
                candy_matrix [project_p][4:3] <= {1'b1,in_stripe};

            set_color_count <= set_color_count+1;
        end else if (sys_state == state_update_map) begin
            for (i=0;i<36;i=i+1)begin
                if (candy_matrix_tmp[i]!=NOTHING)
                    candy_matrix[i][2:0] <= color_Empty;
            end
        end else if (sys_state == state_read_action)begin
            action_count <= action_count + 1;
            if(candy_matrix[action_pos_row[action_count]*6+action_pos_col[action_count]][2:0] != color_Empty)begin

                if (action_type[action_count] == action_Down)begin
                    if (action_pos_row[action_count]<5 && candy_matrix[(action_pos_row[action_count]+1)*6+action_pos_col[action_count]][2:0] != color_Empty)begin
                        candy_matrix[project_p] <= candy_matrix[(action_pos_row[action_count]+1)*6+action_pos_col[action_count]];
                        candy_matrix[(action_pos_row[action_count]+1)*6+action_pos_col[action_count]] <= candy_matrix[project_p];
                        action_run <= 1;
					end else
                        action_run <= 0;
                        
                end else if (action_type[action_count] == action_Up)begin
                    if (action_pos_row[action_count]>0 && candy_matrix[(action_pos_row[action_count]-1)*6+action_pos_col[action_count]][2:0] != color_Empty)begin
                        candy_matrix[project_p] <= candy_matrix[(action_pos_row[action_count]-1)*6+action_pos_col[action_count]];
                        candy_matrix[(action_pos_row[action_count]-1)*6+action_pos_col[action_count]] <= candy_matrix[project_p];
                        action_run <= 1;
                    end else
                        action_run <= 0;

                end else if (action_type[action_count] == action_Left)begin
                    if (action_pos_col[action_count]>0 && candy_matrix[project_p-1][2:0] != color_Empty)begin
                        candy_matrix[project_p] <= candy_matrix[project_p-1];
                        candy_matrix[project_p-1] <= candy_matrix[project_p];
                        action_run <= 1;
                    end else
                        action_run <= 0;

                end else if (action_type[action_count] == action_Right)begin
                    if (action_pos_col[action_count]<5 && candy_matrix[project_p+1][2:0] != color_Empty)begin
                        candy_matrix[project_p] <= candy_matrix[project_p+1];
                        candy_matrix[project_p+1] <= candy_matrix[project_p];
                        action_run <= 1;
                    end else
                        action_run <= 0;

                end
            end else begin
                action_run <= 0;
                // no
            end
        end else if (sys_state == state_output)begin
            set_color_count <= 0;
            action_run <= 0;
            action_count <= 0;
            for (i=0;i<36;i=i+1)begin
                candy_matrix[i] <= 5'b00000;
            end
        end
    end
end




always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        set_action_count <= 0;
    end else begin
        if(in_valid_2 && set_action_count!=10)begin
            action_type [set_action_count] <= in_action;
            action_pos_row [set_action_count] <= in_starting_pos[5:3];
            action_pos_col [set_action_count] <= in_starting_pos[2:0];
            set_action_count <= set_action_count+1;
        end else if (sys_state == state_output)begin
            set_action_count <= 0;
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sys_state <= state_initiai;
    end else begin
        sys_state <= next_state;
    end
end

always@*begin
    case(sys_state)
    state_initiai:begin
        if(in_valid_2) next_state = state_data_in; 
        else           next_state = state_initiai;
    end
    state_data_in:begin
        if(!in_valid_2) next_state = state_check_candy; 
        else            next_state = state_data_in;
    end
    state_check_candy:begin
        if(scan_finish) next_state = state_check_stripe; 
        else            next_state = state_check_candy;
    end
    state_check_stripe:begin
        if(row==6 && col==5) next_state = state_update_map; 
        else                 next_state = state_check_stripe;
    end
    state_update_map:begin
        if(action_count!=set_action_count) next_state = state_read_action; 
        else                               next_state = state_output;
    end
    state_read_action:begin
        if(action_count==set_action_count) next_state = state_output; 
        else           next_state = state_check_action;
        
        // next_state = state_check_action;
    end
    state_check_action:begin
        if(action_run) next_state = state_check_candy; 
        else           next_state = state_read_action;
    end
    default:begin //state_output
        // if(out_valid)  next_state = state_initiai; 
        // else           next_state = state_output;
        next_state = state_initiai;
    end
    endcase
end


assign scan_finish = (row==5);

reg [5:0] i2;

wire row_match_f,col_match_f;
assign row_match_f = |row_match;
assign col_match_f = |col_match;
wire col_p0_empty_n,col_p1_empty_n,col_p2_empty_n,col_p3_empty_n,col_p4_empty_n,col_p5_empty_n;
wire row_p0_empty_n,row_p1_empty_n,row_p2_empty_n,row_p3_empty_n,row_p4_empty_n,row_p5_empty_n;
assign col_p0_empty_n = (candy_matrix[project_col_p0][2:0]!=color_Empty);
assign col_p1_empty_n = (candy_matrix[project_col_p1][2:0]!=color_Empty);
assign col_p2_empty_n = (candy_matrix[project_col_p2][2:0]!=color_Empty);
assign col_p3_empty_n = (candy_matrix[project_col_p3][2:0]!=color_Empty);
assign col_p4_empty_n = (candy_matrix[project_col_p4][2:0]!=color_Empty);
assign col_p5_empty_n = (candy_matrix[project_col_p5][2:0]!=color_Empty);
assign row_p0_empty_n = (candy_matrix[project_row_p0][2:0]!=color_Empty);
assign row_p1_empty_n = (candy_matrix[project_row_p1][2:0]!=color_Empty);
assign row_p2_empty_n = (candy_matrix[project_row_p2][2:0]!=color_Empty);
assign row_p3_empty_n = (candy_matrix[project_row_p3][2:0]!=color_Empty);
assign row_p4_empty_n = (candy_matrix[project_row_p4][2:0]!=color_Empty);
assign row_p5_empty_n = (candy_matrix[project_row_p5][2:0]!=color_Empty);
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        row <= 0;
        col <= 0;
        score_tmp <= 0;
        for(i2=0;i2<36;i2=i2+1)
            candy_matrix_tmp[i2] <= NOTHING;
    end else begin
        if(sys_state == state_check_candy)begin
            if (row!=5)begin
                row <= row+1;
                col <= col+1;
            end else begin
                row <= 0;
                col <= 0;                
            end
            score_tmp <= row_match[0]+row_match[1]+row_match[2]+row_match[3]+
                         col_match[0]+col_match[1]+col_match[2]+col_match[3]+score_tmp;
            
            if((col==0&&(col_match[0])) |row_match[0]) candy_matrix_tmp[project_row_p0] <= set_clr;
            if((col==1&&(col_match[0]|col_match[1])) |row_match[0]|row_match[1]) candy_matrix_tmp[project_row_p1] <= set_clr;
            if((col==2&&(col_match[0]|col_match[1]|col_match[2])) |row_match[0]|row_match[1]|row_match[2]) candy_matrix_tmp[project_row_p2] <= set_clr;
            if((col==3&&(col_match[1]|col_match[2]|col_match[3])) |row_match[1]|row_match[2]|row_match[3]) candy_matrix_tmp[project_row_p3] <= set_clr;
            if((col==4&&(col_match[2]|col_match[3])) |row_match[2]|row_match[3]) candy_matrix_tmp[project_row_p4] <= set_clr;
            if((col==5&&(col_match[3])) |row_match[3]) candy_matrix_tmp[project_row_p5] <= set_clr;

            if(col!=0&&(col_match[0])) candy_matrix_tmp[project_col_p0] <= set_clr;
            if(col!=1&&(col_match[0]|col_match[1])) candy_matrix_tmp[project_col_p1] <= set_clr;
            if(col!=2&&(col_match[0]|col_match[1]|col_match[2])) candy_matrix_tmp[project_col_p2] <= set_clr;
            if(col!=3&&(col_match[1]|col_match[2]|col_match[3])) candy_matrix_tmp[project_col_p3] <= set_clr;
            if(col!=4&&(col_match[2]|col_match[3])) candy_matrix_tmp[project_col_p4] <= set_clr;
            if(col!=5&&(col_match[3])) candy_matrix_tmp[project_col_p5] <= set_clr;
        end else if(sys_state == state_check_stripe) begin
            // $display("actcount %d",action_count);
            if (row<6)begin
                row <= row +1;

                if( (candy_matrix[project_row_p0][4:3]==2'b10&&candy_matrix_tmp[project_row_p0]==set_clr)|
                    (candy_matrix[project_row_p1][4:3]==2'b10&&candy_matrix_tmp[project_row_p1]==set_clr)|
                    (candy_matrix[project_row_p2][4:3]==2'b10&&candy_matrix_tmp[project_row_p2]==set_clr)|
                    (candy_matrix[project_row_p3][4:3]==2'b10&&candy_matrix_tmp[project_row_p3]==set_clr)|
                    (candy_matrix[project_row_p4][4:3]==2'b10&&candy_matrix_tmp[project_row_p4]==set_clr)|
                    (candy_matrix[project_row_p5][4:3]==2'b10&&candy_matrix_tmp[project_row_p5]==set_clr)) begin
                    if(row_match_f)begin
                        if(candy_matrix_tmp[project_row_p0]==NOTHING)
                            candy_matrix_tmp[project_row_p0]<=set_dead;
                        if(candy_matrix_tmp[project_row_p1]==NOTHING)
                            candy_matrix_tmp[project_row_p1]<=set_dead;
                        if(candy_matrix_tmp[project_row_p2]==NOTHING)
                            candy_matrix_tmp[project_row_p2]<=set_dead;
                        if(candy_matrix_tmp[project_row_p3]==NOTHING)
                            candy_matrix_tmp[project_row_p3]<=set_dead;
                        if(candy_matrix_tmp[project_row_p4]==NOTHING)
                            candy_matrix_tmp[project_row_p4]<=set_dead;
                        if(candy_matrix_tmp[project_row_p5]==NOTHING)
                            candy_matrix_tmp[project_row_p5]<=set_dead;
                        score_tmp <= score_tmp+
                                    (row_p0_empty_n&&candy_matrix_tmp[project_row_p0]==NOTHING)+
                                    (row_p1_empty_n&&candy_matrix_tmp[project_row_p1]==NOTHING)+
                                    (row_p2_empty_n&&candy_matrix_tmp[project_row_p2]==NOTHING)+
                                    (row_p3_empty_n&&candy_matrix_tmp[project_row_p3]==NOTHING)+
                                    (row_p4_empty_n&&candy_matrix_tmp[project_row_p4]==NOTHING)+
                                    (row_p5_empty_n&&candy_matrix_tmp[project_row_p5]==NOTHING);             
                    end else begin
                        candy_matrix_tmp[project_row_p0]<=set_dead;
                        candy_matrix_tmp[project_row_p1]<=set_dead;
                        candy_matrix_tmp[project_row_p2]<=set_dead;
                        candy_matrix_tmp[project_row_p3]<=set_dead;
                        candy_matrix_tmp[project_row_p4]<=set_dead;
                        candy_matrix_tmp[project_row_p5]<=set_dead;
                        score_tmp <= score_tmp+
                                    (row_p0_empty_n&&candy_matrix_tmp[project_row_p0]!=set_dead)+
                                    (row_p1_empty_n&&candy_matrix_tmp[project_row_p1]!=set_dead)+
                                    (row_p2_empty_n&&candy_matrix_tmp[project_row_p2]!=set_dead)+
                                    (row_p3_empty_n&&candy_matrix_tmp[project_row_p3]!=set_dead)+
                                    (row_p4_empty_n&&candy_matrix_tmp[project_row_p4]!=set_dead)+
                                    (row_p5_empty_n&&candy_matrix_tmp[project_row_p5]!=set_dead)-1; 
                    end
                end

            end else begin
                col <= col +1;
                if( (candy_matrix[project_col_p0][4:3]==2'b11&&candy_matrix_tmp[project_col_p0]==set_clr)|
                    (candy_matrix[project_col_p1][4:3]==2'b11&&candy_matrix_tmp[project_col_p1]==set_clr)|
                    (candy_matrix[project_col_p2][4:3]==2'b11&&candy_matrix_tmp[project_col_p2]==set_clr)|
                    (candy_matrix[project_col_p3][4:3]==2'b11&&candy_matrix_tmp[project_col_p3]==set_clr)|
                    (candy_matrix[project_col_p4][4:3]==2'b11&&candy_matrix_tmp[project_col_p4]==set_clr)|
                    (candy_matrix[project_col_p5][4:3]==2'b11&&candy_matrix_tmp[project_col_p5]==set_clr)) begin
                    if(col_match_f)begin
                        if(candy_matrix_tmp[project_col_p0]==NOTHING)
                            candy_matrix_tmp[project_col_p0]<=set_dead;
                        if(candy_matrix_tmp[project_col_p1]==NOTHING)
                            candy_matrix_tmp[project_col_p1]<=set_dead;
                        if(candy_matrix_tmp[project_col_p2]==NOTHING)
                            candy_matrix_tmp[project_col_p2]<=set_dead;
                        if(candy_matrix_tmp[project_col_p3]==NOTHING)
                            candy_matrix_tmp[project_col_p3]<=set_dead;
                        if(candy_matrix_tmp[project_col_p4]==NOTHING)
                            candy_matrix_tmp[project_col_p4]<=set_dead;
                        if(candy_matrix_tmp[project_col_p5]==NOTHING)
                            candy_matrix_tmp[project_col_p5]<=set_dead;
                        score_tmp <= score_tmp+
                                    (col_p0_empty_n&&candy_matrix_tmp[project_col_p0]==NOTHING)+
                                    (col_p1_empty_n&&candy_matrix_tmp[project_col_p1]==NOTHING)+
                                    (col_p2_empty_n&&candy_matrix_tmp[project_col_p2]==NOTHING)+
                                    (col_p3_empty_n&&candy_matrix_tmp[project_col_p3]==NOTHING)+
                                    (col_p4_empty_n&&candy_matrix_tmp[project_col_p4]==NOTHING)+
                                    (col_p5_empty_n&&candy_matrix_tmp[project_col_p5]==NOTHING);             
                    end else begin
                        candy_matrix_tmp[project_col_p0]<=set_dead;
                        candy_matrix_tmp[project_col_p1]<=set_dead;
                        candy_matrix_tmp[project_col_p2]<=set_dead;
                        candy_matrix_tmp[project_col_p3]<=set_dead;
                        candy_matrix_tmp[project_col_p4]<=set_dead;
                        candy_matrix_tmp[project_col_p5]<=set_dead;
                        score_tmp <= score_tmp+
                                    (col_p0_empty_n&&candy_matrix_tmp[project_col_p0]!=set_dead)+
                                    (col_p1_empty_n&&candy_matrix_tmp[project_col_p1]!=set_dead)+
                                    (col_p2_empty_n&&candy_matrix_tmp[project_col_p2]!=set_dead)+
                                    (col_p3_empty_n&&candy_matrix_tmp[project_col_p3]!=set_dead)+
                                    (col_p4_empty_n&&candy_matrix_tmp[project_col_p4]!=set_dead)+
                                    (col_p5_empty_n&&candy_matrix_tmp[project_col_p5]!=set_dead)-1; 
                    end
                end

            end
            
        end else if(sys_state == state_update_map) begin
            row <= 0;
            col <= 0; 
            for(i2=0;i2<36;i2=i2+1)
                candy_matrix_tmp[i2] <= NOTHING;
        end else if (sys_state == state_initiai) begin
            row <= 0;
            col <= 0;
            
            for(i2=0;i2<36;i2=i2+1)
                candy_matrix_tmp[i2] <=NOTHING;
            score_tmp <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_valid <= 0;
        out_score <= 0;
    end else if (sys_state == state_output) begin
        out_score <= score_tmp;
        out_valid <= 1'b1;
    end else if (sys_state == state_initiai) begin
        out_valid <= 0;
        out_score <= 0;
    end
end

endmodule

// module legal_action(
//     input [1:0] action_type,
//     input [2:0] action_pos_row,action_pos_col,
//     output legal
// );

// parameter action_Up    = 2'b00,
//           action_Down  = 2'b01,
//           action_Left  = 2'b10,
//           action_Right = 2'b11;
// always@*begin
//     if(action_pos_row)
// end
/*********************************************/

