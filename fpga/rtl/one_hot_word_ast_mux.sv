module one_hot_word_ast_mux #(
  parameter int AST_SYMBOLS = 1,
  parameter int BYTE_W      = 8
)(
  input                                                 clk_i,
  input                                                 srst_i,
/*
  input  [IN_DIRS_CNT-1:0][AST_SYMBOLS-1:0][BYTE_W-1:0] ast_sink_data_i,
  output [IN_DIRS_CNT-1:0]                              ast_sink_ready_o,
  input  [IN_DIRS_CNT-1:0]                              ast_sink_valid_i,
*/


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink0_data_i,
  output                          ast_sink0_ready_o,
  input                           ast_sink0_valid_i,

  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink1_data_i,
  output                          ast_sink1_ready_o,
  input                           ast_sink1_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink2_data_i,
  output                          ast_sink2_ready_o,
  input                           ast_sink2_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink3_data_i,
  output                          ast_sink3_ready_o,
  input                           ast_sink3_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink4_data_i,
  output                          ast_sink4_ready_o,
  input                           ast_sink4_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink5_data_i,
  output                          ast_sink5_ready_o,
  input                           ast_sink5_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink6_data_i,
  output                          ast_sink6_ready_o,
  input                           ast_sink6_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink7_data_i,
  output                          ast_sink7_ready_o,
  input                           ast_sink7_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink8_data_i,
  output                          ast_sink8_ready_o,
  input                           ast_sink8_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink9_data_i,
  output                          ast_sink9_ready_o,
  input                           ast_sink9_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink10_data_i,
  output                          ast_sink10_ready_o,
  input                           ast_sink10_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink11_data_i,
  output                          ast_sink11_ready_o,
  input                           ast_sink11_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink12_data_i,
  output                          ast_sink12_ready_o,
  input                           ast_sink12_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink13_data_i,
  output                          ast_sink13_ready_o,
  input                           ast_sink13_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink14_data_i,
  output                          ast_sink14_ready_o,
  input                           ast_sink14_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink15_data_i,
  output                          ast_sink15_ready_o,
  input                           ast_sink15_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink16_data_i,
  output                          ast_sink16_ready_o,
  input                           ast_sink16_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink17_data_i,
  output                          ast_sink17_ready_o,
  input                           ast_sink17_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink18_data_i,
  output                          ast_sink18_ready_o,
  input                           ast_sink18_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink19_data_i,
  output                          ast_sink19_ready_o,
  input                           ast_sink19_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink20_data_i,
  output                          ast_sink20_ready_o,
  input                           ast_sink20_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink21_data_i,
  output                          ast_sink21_ready_o,
  input                           ast_sink21_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink22_data_i,
  output                          ast_sink22_ready_o,
  input                           ast_sink22_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink23_data_i,
  output                          ast_sink23_ready_o,
  input                           ast_sink23_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink24_data_i,
  output                          ast_sink24_ready_o,
  input                           ast_sink24_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink25_data_i,
  output                          ast_sink25_ready_o,
  input                           ast_sink25_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink26_data_i,
  output                          ast_sink26_ready_o,
  input                           ast_sink26_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink27_data_i,
  output                          ast_sink27_ready_o,
  input                           ast_sink27_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink28_data_i,
  output                          ast_sink28_ready_o,
  input                           ast_sink28_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink29_data_i,
  output                          ast_sink29_ready_o,
  input                           ast_sink29_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink30_data_i,
  output                          ast_sink30_ready_o,
  input                           ast_sink30_valid_i,


  input  [AST_SYMBOLS*BYTE_W-1:0] ast_sink31_data_i,
  output                          ast_sink31_ready_o,
  input                           ast_sink31_valid_i,


  output [AST_SYMBOLS*BYTE_W-1:0]                  ast_source_data_o,
  input                                            ast_source_ready_i,
  output                                           ast_source_valid_o
);

parameter IN_DIRS_CNT = 32;

logic [IN_DIRS_CNT-1:0][AST_SYMBOLS*BYTE_W-1:0] ast_sink_data_i;
logic [IN_DIRS_CNT-1:0]                         ast_sink_ready_o;
logic [IN_DIRS_CNT-1:0]                         ast_sink_valid_i;

always_comb
  begin
    ast_sink_data_i          [0] =  ast_sink0_data_i;           
    ast_sink_valid_i         [0] =  ast_sink0_valid_i;
    ast_sink0_ready_o            =  ast_sink_ready_o[0];

    
    ast_sink_data_i          [1] =  ast_sink1_data_i;           
    ast_sink_valid_i         [1] =  ast_sink1_valid_i;
    ast_sink1_ready_o            =  ast_sink_ready_o[1];

    ast_sink_data_i          [2] =  ast_sink2_data_i;           
    ast_sink_valid_i         [2] =  ast_sink2_valid_i;
    ast_sink2_ready_o            =  ast_sink_ready_o[2];

    ast_sink_data_i          [3] =  ast_sink3_data_i;           
    ast_sink_valid_i         [3] =  ast_sink3_valid_i;
    ast_sink3_ready_o            =  ast_sink_ready_o[3];

    ast_sink_data_i          [4] =  ast_sink4_data_i;           
    ast_sink_valid_i         [4] =  ast_sink4_valid_i;
    ast_sink4_ready_o            =  ast_sink_ready_o[4];

    ast_sink_data_i          [5] =  ast_sink5_data_i;           
    ast_sink_valid_i         [5] =  ast_sink5_valid_i;
    ast_sink5_ready_o            =  ast_sink_ready_o[5];

    ast_sink_data_i          [6] =  ast_sink6_data_i;           
    ast_sink_valid_i         [6] =  ast_sink6_valid_i;
    ast_sink6_ready_o            =  ast_sink_ready_o[6];

    ast_sink_data_i          [7] =  ast_sink7_data_i;           
    ast_sink_valid_i         [7] =  ast_sink7_valid_i;
    ast_sink7_ready_o            =  ast_sink_ready_o[7];

    ast_sink_data_i          [8] =  ast_sink8_data_i;           
    ast_sink_valid_i         [8] =  ast_sink8_valid_i;
    ast_sink8_ready_o            =  ast_sink_ready_o[8];

    ast_sink_data_i          [9] =  ast_sink9_data_i;           
    ast_sink_valid_i         [9] =  ast_sink9_valid_i;
    ast_sink9_ready_o            =  ast_sink_ready_o[9];

    ast_sink_data_i          [10] =  ast_sink10_data_i;           
    ast_sink_valid_i         [10] =  ast_sink10_valid_i;
    ast_sink10_ready_o            =  ast_sink_ready_o[10];

    ast_sink_data_i          [11] =  ast_sink11_data_i;           
    ast_sink_valid_i         [11] =  ast_sink11_valid_i;
    ast_sink11_ready_o            =  ast_sink_ready_o[11];

    ast_sink_data_i          [12] =  ast_sink12_data_i;           
    ast_sink_valid_i         [12] =  ast_sink12_valid_i;
    ast_sink12_ready_o            =  ast_sink_ready_o[12];

    ast_sink_data_i          [13] =  ast_sink13_data_i;           
    ast_sink_valid_i         [13] =  ast_sink13_valid_i;
    ast_sink13_ready_o            =  ast_sink_ready_o[13];

    ast_sink_data_i          [14] =  ast_sink14_data_i;           
    ast_sink_valid_i         [14] =  ast_sink14_valid_i;
    ast_sink14_ready_o            =  ast_sink_ready_o[14];

    ast_sink_data_i          [15] =  ast_sink15_data_i;           
    ast_sink_valid_i         [15] =  ast_sink15_valid_i;
    ast_sink15_ready_o            =  ast_sink_ready_o[15];

    ast_sink_data_i          [16] =  ast_sink16_data_i;           
    ast_sink_valid_i         [16] =  ast_sink16_valid_i;
    ast_sink16_ready_o            =  ast_sink_ready_o[16];

    ast_sink_data_i          [17] =  ast_sink17_data_i;           
    ast_sink_valid_i         [17] =  ast_sink17_valid_i;
    ast_sink17_ready_o            =  ast_sink_ready_o[17];

    ast_sink_data_i          [18] =  ast_sink18_data_i;           
    ast_sink_valid_i         [18] =  ast_sink18_valid_i;
    ast_sink18_ready_o            =  ast_sink_ready_o[18];

    ast_sink_data_i          [19] =  ast_sink19_data_i;           
    ast_sink_valid_i         [19] =  ast_sink19_valid_i;
    ast_sink19_ready_o            =  ast_sink_ready_o[19];

    ast_sink_data_i          [20] =  ast_sink20_data_i;           
    ast_sink_valid_i         [20] =  ast_sink20_valid_i;
    ast_sink20_ready_o            =  ast_sink_ready_o[20];

    ast_sink_data_i          [21] =  ast_sink21_data_i;           
    ast_sink_valid_i         [21] =  ast_sink21_valid_i;
    ast_sink21_ready_o            =  ast_sink_ready_o[21];

    ast_sink_data_i          [22] =  ast_sink22_data_i;           
    ast_sink_valid_i         [22] =  ast_sink22_valid_i;
    ast_sink22_ready_o            =  ast_sink_ready_o[22];

    ast_sink_data_i          [23] =  ast_sink23_data_i;           
    ast_sink_valid_i         [23] =  ast_sink23_valid_i;
    ast_sink23_ready_o            =  ast_sink_ready_o[23];

    ast_sink_data_i          [24] =  ast_sink24_data_i;           
    ast_sink_valid_i         [24] =  ast_sink24_valid_i;
    ast_sink24_ready_o            =  ast_sink_ready_o[24];

    ast_sink_data_i          [25] =  ast_sink25_data_i;           
    ast_sink_valid_i         [25] =  ast_sink25_valid_i;
    ast_sink25_ready_o            =  ast_sink_ready_o[25];

    ast_sink_data_i          [26] =  ast_sink26_data_i;           
    ast_sink_valid_i         [26] =  ast_sink26_valid_i;
    ast_sink26_ready_o            =  ast_sink_ready_o[26];

    ast_sink_data_i          [27] =  ast_sink27_data_i;           
    ast_sink_valid_i         [27] =  ast_sink27_valid_i;
    ast_sink27_ready_o            =  ast_sink_ready_o[27];

    ast_sink_data_i          [28] =  ast_sink28_data_i;           
    ast_sink_valid_i         [28] =  ast_sink28_valid_i;
    ast_sink28_ready_o            =  ast_sink_ready_o[28];

    ast_sink_data_i          [29] =  ast_sink29_data_i;           
    ast_sink_valid_i         [29] =  ast_sink29_valid_i;
    ast_sink29_ready_o            =  ast_sink_ready_o[29];

    ast_sink_data_i          [30] =  ast_sink30_data_i;           
    ast_sink_valid_i         [30] =  ast_sink30_valid_i;
    ast_sink30_ready_o            =  ast_sink_ready_o[30];

    ast_sink_data_i          [31] =  ast_sink31_data_i;           
    ast_sink_valid_i         [31] =  ast_sink31_valid_i;
    ast_sink31_ready_o            =  ast_sink_ready_o[31];
  end                               

localparam IN_DIRS_LOG2 = ( IN_DIRS_CNT == 1      ) ? 
                          ( 1                     ) : 
                          ( $clog2( IN_DIRS_CNT ) );

logic [IN_DIRS_CNT-1:0]  in_ready_w;

logic [IN_DIRS_LOG2-1:0] next_select_num;
logic [IN_DIRS_LOG2-1:0] select_num;
logic                    packet_in_progress;

assign ast_sink_ready_o = in_ready_w;

one_hot_arb #( 
  .REQ_NUM  ( IN_DIRS_CNT         )
) oh_arb (
  .req_i    ( ast_sink_valid_i    ),
  .num_o    ( next_select_num     )
);

always_ff @( posedge clk_i ) 
  begin
    if( srst_i ) 
      begin
        select_num         <= 0;
        packet_in_progress <= 0;
      end 
    else 
      begin
        if( !ast_source_valid_o && !packet_in_progress ) 
          begin
             select_num <= next_select_num;
          end 
        else 
          begin
             packet_in_progress <= 1;
          end

        if( ast_source_valid_o && ast_source_ready_i ) 
          begin
             select_num         <= next_select_num;
             packet_in_progress <= 0;
          end
      end
  end

assign ast_source_data_o          = ast_sink_data_i[ select_num ];
assign ast_source_valid_o         = ast_sink_valid_i[ select_num ];

always_comb
  begin
    in_ready_w               = '0;
    in_ready_w[ select_num ] = ast_source_ready_i;
  end

endmodule
