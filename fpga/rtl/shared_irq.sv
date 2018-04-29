module shared_irq (
  input        clk_i,
  input        rst_i,
  input        irq0_i,
  input        irq1_i,
  output logic irq_o
);

always_ff @( posedge clk_i or posedge rst_i )
  begin
    if( rst_i )
      irq_o <= 1'b0;
    else
      irq_o <= ( irq0_i || irq1_i );
  end

endmodule
