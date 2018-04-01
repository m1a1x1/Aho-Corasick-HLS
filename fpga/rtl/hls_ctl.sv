module hls_ctl(
  input clk_i,
  input rst_i,

  input [31:0]           slv_writedata,
  input                  slv_write,
  output logic [31:0]    slv_readdata,
  output logic           slv_readdata_valid,
  input                  slv_read,
  output logic           slv_waitrequest,

  output logic [63:0]    ptr_o
);


always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      ptr_o <= 0;
    else
      begin
        if( slv_write )
          ptr_o <= { 32'b0, slv_writedata};
      end
  end

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      slv_readdata <= 0;
    else
      slv_readdata <= ptr_o;
  end

always_ff @( posedge clk_i )
  slv_readdata_valid <= slv_read;

assign slv_waitrequest = 0;
endmodule
