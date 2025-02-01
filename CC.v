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

parameter color_Red    = 5'b00000,
          color_Blue   = 5'b00001,
          color_Green  = 5'b00010,
          color_Yellow = 5'b00011,
          color_Orange = 5'b00100,
          color_Purple = 5'b00101,
          color_Empty  = 5'b00111;

parameter action_Up    = 2'b00,
          action_Down  = 2'b01,
          action_Left  = 2'b10,
          action_Right = 2'b11;

parameter stripe_horizontal = 1'b0,
          stripe_vertical   = 1'b1;

assign project_p = (row_d_six)+col;
assign row_d_six = row*6;
assign col_d_six = 6;
assign project_row_p0 = row_d_six;
assign project_row_p1 = row_d_six+1;
assign project_row_p2 = row_d_six+2;
assign project_row_p3 = row_d_six+3;
assign project_row_p4 = row_d_six+4;
assign project_row_p5 = row_d_six+5;
assign project_col_p0 = col;
assign project_col_p1 = col+col_d_six;
assign project_col_p2 = col+{col_d_six,1'b0};
assign project_col_p3 = project_col_p1+{col_d_six,1'b0};
assign project_col_p4 = col+{col_d_six,2'b00};
assign project_col_p5 = project_col_p1+{col_d_six,2'b00};
wire [3:0] row_match,col_match;
match_6 my_match_col(
    .block_in_0(candy_matrix[project_col_p0]),
    .block_in_1(candy_matrix[project_col_p1]),
    .block_in_2(candy_matrix[project_col_p2]),
    .block_in_3(candy_matrix[project_col_p3]),
    .block_in_4(candy_matrix[project_col_p4]),
    .block_in_5(candy_matrix[project_col_p5]),
    .match_out(col_match)
);
match_6 my_match_row(
    .block_in_0(candy_matrix[project_row_p0]),
    .block_in_1(candy_matrix[project_row_p1]),
    .block_in_2(candy_matrix[project_row_p2]),
    .block_in_3(candy_matrix[project_row_p3]),
    .block_in_4(candy_matrix[project_row_p4]),
    .block_in_5(candy_matrix[project_row_p5]),
    .match_out(row_match)
);
reg [6:0] set_color_count;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        set_color_count <= 0;
    end else begin
        if(in_valid_1 && set_color_count!=36)begin // not must
            candy_matrix [set_color_count] <= in_color;
            set_color_count <= set_color_count+1;
        end else if (!in_valid_1)begin
            set_color_count <= 0;
        end
    end
end
reg stripe_candy_type [0:3];
reg [2:0] stripe_candy_pos_row [0:3];
reg [2:0] stripe_candy_pos_col [0:3];
reg [2:0] set_stripe_count;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        set_stripe_count <= 0;
    end else begin
        if(in_valid_1 && set_stripe_count!=4)begin
            stripe_candy_type [set_stripe_count] <= in_stripe;
            stripe_candy_pos_row [set_stripe_count] <= in_starting_pos[5:3];
            stripe_candy_pos_col [set_stripe_count] <= in_starting_pos[2:0];
            set_stripe_count <= set_stripe_count+1;
        end else if (!in_valid_1)begin
            set_stripe_count <= 0;
        end
    end
end

reg [1:0] action_type [0:3];
reg [2:0] action_pos_row [0:3];
reg [2:0] action_pos_col [0:3];
reg [3:0] set_action_count;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        set_action_count <= 0;
    end else begin
        if(in_valid_2 && set_action_count!=10)begin
            action_type [set_action_count] <= in_action;
            action_pos_row [set_action_count] <= in_starting_pos[5:3];
            action_pos_col [set_action_count] <= in_starting_pos[2:0];
            set_action_count <= set_action_count+1;
        end else if (!in_valid_1)begin
            set_action_count <= 0;
        end
    end
end
reg [2:0] sys_state;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        sys_state <= 2'b00;
    end else begin
        sys_state <= next_state;
    end
end
always@*begin
    case(sys_state)
    0:begin
        if(in_valid_2) next_state = 1; else next_state = 0;
    end
    1:begin
        if(!in_valid_2) next_state = 2; else next_state = 1;
    end
    2:begin
        if(scan_finish) next_state = 3; else next_state = 2;
    end
    3:begin
        if(action_clr) next_state = 4; else next_state = 2;
    end
    default:
        if(in_valid_1) next_state = 0; else next_state = 4;
    endcase
end

wire scan_finish;
assign scan_finish = (row==5)? 1'b1:1'b0;
reg [1:0] score_tmp;
reg [2:0] candy_matrix_tmp [0:35];
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        row <= 0;
        col <= 0;
        score_tmp <= 0;
    end else begin
        if(sys_state==2)begin
            row <= row+1;
            col <= col+1;
            score_tmp <= row_match[0]+row_match[1]+row_match[2]+row_match[3]+
                         col_match[0]+col_match[1]+col_match[2]+col_match[3]+score_tmp;
            
            candy_matrix_tmp
        end else begin
            row <= 0;
            col <= 0;
            if (sys_state==0)
                score_tmp <= 0;
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        candy_matrix_tmp[0]<=0;
    end else begin
        if(sys_state==2)begin

            if((col==0&&(col_match[0])) |row_match[0]) candy_matrix_tmp[project_row_p0] <= color_Empty;
            if((col==1&&(col_match[0]|col_match[1])) |row_match[0]|row_match[1]) candy_matrix_tmp[project_row_p1] <= color_Empty;
            if((col==2&&(col_match[0]|col_match[1]|col_match[2])) |row_match[0]|row_match[1]|row_match[2]) candy_matrix_tmp[project_row_p2] <= color_Empty;
            if((col==3&&(col_match[1]|col_match[2]|col_match[3])) |row_match[1]|row_match[2]|row_match[3]) candy_matrix_tmp[project_row_p3] <= color_Empty;
            if((col==4&&(col_match[2]|col_match[3])) |row_match[2]|row_match[3]) candy_matrix_tmp[project_row_p4] <= color_Empty;
            if((col==5&&(col_match[3])) |row_match[3]) candy_matrix_tmp[project_row_p5] <= color_Empty;

            if(col!=0&&(col_match[0])) candy_matrix_tmp[project_col_p0] <= color_Empty;
            if(col!=1&&(col_match[0]|col_match[1])) candy_matrix_tmp[project_col_p1] <= color_Empty;
            if(col!=2&&(col_match[0]|col_match[1]|col_match[2])) candy_matrix_tmp[project_col_p2] <= color_Empty;
            if(col!=3&&(col_match[1]|col_match[2]|col_match[3])) candy_matrix_tmp[project_col_p3] <= color_Empty;
            if(col!=4&&(col_match[2]|col_match[3])) candy_matrix_tmp[project_col_p4] <= color_Empty;
            if(col!=5&&(col_match[3])) candy_matrix_tmp[project_col_p5] <= color_Empty;
            
            
        end else if(sys_state==3)begin
            update_count <= update_count+1;
            if (candy_matrix_tmp[update_count])
            
        end else begin

        end
    end
end

assign project_p0 = row_d_six;
assign project_p1 = row_d_six+1;
assign project_p2 = row_d_six+2;
assign project_p3 = row_d_six+3;
assign project_p4 = row_d_six+4;
assign project_p5 = row_d_six+5;
// assign project_p6 = col;
assign project_p7 = (col!=1)? col+col_d_six:col;
assign project_p8 = (col!=2)?col+{col_d_six,1'b0}:col+col_d_six;
assign project_p9 = (col!=3)?project_col_p1+{col_d_six,1'b0}:col+{col_d_six,1'b0};
assign project_p10 = (col!=4)?col+{col_d_six,2'b00}:project_col_p1;
assign project_p11 = (col!=5)?project_col_p1+{col_d_six,2'b00}:col+{col_d_six,2'b00};


endmodule

/*********************************************/

