module hls_ctl(
  input                  clk_i,
  input                  rst_i,

  input [31:0]           slv0_writedata,
  input                  slv0_write,
  input                  slv0_address,
  output logic [31:0]    slv0_readdata,
  output logic           slv0_readdata_valid,
  input                  slv0_read,
  output logic           slv0_waitrequest,


  input [63:0]           slv1_writedata,
  input                  slv1_write,

  output logic           rst_o,
  output logic [63:0]    ptr_o
);

logic rst;

assign rst = ( slv0_address == 1'b1 ) && slv0_write;

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      ptr_o <= '0;
    else
      begin
        if( slv0_write )
          begin
            if( slv0_address == 0 )
              ptr_o <= { 32'b0, slv0_writedata};
          end
      end
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      slv0_readdata <= 0;
    else
      begin
        if( slv1_write )
          slv0_readdata <= slv1_writedata[31:0];
      end
  end

always_ff @( posedge clk_i )
  slv0_readdata_valid <= slv0_read;

assign slv0_waitrequest = 0;

assign rst_o = rst_i || rst;

endmodule
