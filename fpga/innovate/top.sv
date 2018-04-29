
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module top(

    //////////// CLOCK //////////
    input               FPGA_CLK1_50,
    input               FPGA_CLK2_50,
    input               FPGA_CLK3_50,

    //////////// HDMI //////////
    inout               HDMI_I2C_SCL,
    inout               HDMI_I2C_SDA,
    inout               HDMI_I2S,
    inout               HDMI_LRCLK,
    inout               HDMI_MCLK,
    inout               HDMI_SCLK,
    output              HDMI_TX_CLK,
    output   [23: 0]    HDMI_TX_D,
    output              HDMI_TX_DE,
    output              HDMI_TX_HS,
    input               HDMI_TX_INT,
    output              HDMI_TX_VS,

    //////////// HPS //////////
    inout               HPS_CONV_USB_N,
    output   [14: 0]    HPS_DDR3_ADDR,
    output   [ 2: 0]    HPS_DDR3_BA,
    output              HPS_DDR3_CAS_N,
    output              HPS_DDR3_CK_N,
    output              HPS_DDR3_CK_P,
    output              HPS_DDR3_CKE,
    output              HPS_DDR3_CS_N,
    output   [ 3: 0]    HPS_DDR3_DM,
    inout    [31: 0]    HPS_DDR3_DQ,
    inout    [ 3: 0]    HPS_DDR3_DQS_N,
    inout    [ 3: 0]    HPS_DDR3_DQS_P,
    output              HPS_DDR3_ODT,
    output              HPS_DDR3_RAS_N,
    output              HPS_DDR3_RESET_N,
    input               HPS_DDR3_RZQ,
    output              HPS_DDR3_WE_N,
    output              HPS_ENET_GTX_CLK,
    inout               HPS_ENET_INT_N,
    output              HPS_ENET_MDC,
    inout               HPS_ENET_MDIO,
    input               HPS_ENET_RX_CLK,
    input    [ 3: 0]    HPS_ENET_RX_DATA,
    input               HPS_ENET_RX_DV,
    output   [ 3: 0]    HPS_ENET_TX_DATA,
    output              HPS_ENET_TX_EN,
    inout               HPS_GSENSOR_INT,
    inout               HPS_I2C0_SCLK,
    inout               HPS_I2C0_SDAT,
    inout               HPS_I2C1_SCLK,
    inout               HPS_I2C1_SDAT,
    inout               HPS_KEY,
    inout               HPS_LED,
    inout               HPS_LTC_GPIO,
    output              HPS_SD_CLK,
    inout               HPS_SD_CMD,
    inout    [ 3: 0]    HPS_SD_DATA,
    output              HPS_SPIM_CLK,
    input               HPS_SPIM_MISO,
    output              HPS_SPIM_MOSI,
    inout               HPS_SPIM_SS,
    input               HPS_UART_RX,
    output              HPS_UART_TX,
    input               HPS_USB_CLKOUT,
    inout    [ 7: 0]    HPS_USB_DATA,
    input               HPS_USB_DIR,
    input               HPS_USB_NXT,
    output              HPS_USB_STP,

    //////////// LED //////////
    output   [ 7: 0]    LED,

    input gpio0, 
    input gpio4, 
    input gpio8, 
     
    output gpio1,
    output gpio2,
    output gpio3,
    output gpio9,
     
    output gpio5,
    output gpio6,
    output gpio7  
   
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
wire hps_fpga_reset_n;
wire     [6: 0]     fpga_led_internal;
wire                fpga_clk_50;
// connection of internal logics
assign LED[7: 1] = fpga_led_internal;
assign fpga_clk_50 = FPGA_CLK1_50;



logic [7:0]  str_data;
logic        str_valid_tmp;
logic        str_valid;
logic        str_ready;
logic [31:0] str_ready_per_module;
logic        str_startofpacket;
logic        str_endofpacket;
	



//=======================================================
//  Structural coding
//=======================================================
soc_system u0(
               //Clock&Reset
               .clk_in_clk(FPGA_CLK1_50),                                      //                            clk.clk
	       .hps_0_f2h_cold_reset_req_reset_n (1'b1),
               //HPS ddr3
               .memory_mem_a(HPS_DDR3_ADDR),                                //                         memory.mem_a
               .memory_mem_ba(HPS_DDR3_BA),                                 //                               .mem_ba
               .memory_mem_ck(HPS_DDR3_CK_P),                               //                               .mem_ck
               .memory_mem_ck_n(HPS_DDR3_CK_N),                             //                               .mem_ck_n
               .memory_mem_cke(HPS_DDR3_CKE),                               //                               .mem_cke
               .memory_mem_cs_n(HPS_DDR3_CS_N),                             //                               .mem_cs_n
               .memory_mem_ras_n(HPS_DDR3_RAS_N),                           //                               .mem_ras_n
               .memory_mem_cas_n(HPS_DDR3_CAS_N),                           //                               .mem_cas_n
               .memory_mem_we_n(HPS_DDR3_WE_N),                             //                               .mem_we_n
               .memory_mem_reset_n(HPS_DDR3_RESET_N),                       //                               .mem_reset_n
               .memory_mem_dq(HPS_DDR3_DQ),                                 //                               .mem_dq
               .memory_mem_dqs(HPS_DDR3_DQS_P),                             //                               .mem_dqs
               .memory_mem_dqs_n(HPS_DDR3_DQS_N),                           //                               .mem_dqs_n
               .memory_mem_odt(HPS_DDR3_ODT),                               //                               .mem_odt
               .memory_mem_dm(HPS_DDR3_DM),                                 //                               .mem_dm
               .memory_oct_rzqin(HPS_DDR3_RZQ),                             //                               .oct_rzqin
               //HPS ethernet
               .hps_0_hps_io_hps_io_emac1_inst_TX_CLK(HPS_ENET_GTX_CLK),    //                   hps_0_hps_io.hps_io_emac1_inst_TX_CLK
               .hps_0_hps_io_hps_io_emac1_inst_TXD0(HPS_ENET_TX_DATA[0]),   //                               .hps_io_emac1_inst_TXD0
               .hps_0_hps_io_hps_io_emac1_inst_TXD1(HPS_ENET_TX_DATA[1]),   //                               .hps_io_emac1_inst_TXD1
               .hps_0_hps_io_hps_io_emac1_inst_TXD2(HPS_ENET_TX_DATA[2]),   //                               .hps_io_emac1_inst_TXD2
               .hps_0_hps_io_hps_io_emac1_inst_TXD3(HPS_ENET_TX_DATA[3]),   //                               .hps_io_emac1_inst_TXD3
               .hps_0_hps_io_hps_io_emac1_inst_RXD0(HPS_ENET_RX_DATA[0]),   //                               .hps_io_emac1_inst_RXD0
               .hps_0_hps_io_hps_io_emac1_inst_MDIO(HPS_ENET_MDIO),         //                               .hps_io_emac1_inst_MDIO
               .hps_0_hps_io_hps_io_emac1_inst_MDC(HPS_ENET_MDC),           //                               .hps_io_emac1_inst_MDC
               .hps_0_hps_io_hps_io_emac1_inst_RX_CTL(HPS_ENET_RX_DV),      //                               .hps_io_emac1_inst_RX_CTL
               .hps_0_hps_io_hps_io_emac1_inst_TX_CTL(HPS_ENET_TX_EN),      //                               .hps_io_emac1_inst_TX_CTL
               .hps_0_hps_io_hps_io_emac1_inst_RX_CLK(HPS_ENET_RX_CLK),     //                               .hps_io_emac1_inst_RX_CLK
               .hps_0_hps_io_hps_io_emac1_inst_RXD1(HPS_ENET_RX_DATA[1]),   //                               .hps_io_emac1_inst_RXD1
               .hps_0_hps_io_hps_io_emac1_inst_RXD2(HPS_ENET_RX_DATA[2]),   //                               .hps_io_emac1_inst_RXD2
               .hps_0_hps_io_hps_io_emac1_inst_RXD3(HPS_ENET_RX_DATA[3]),   //                               .hps_io_emac1_inst_RXD3
               //HPS SD card
               .hps_0_hps_io_hps_io_sdio_inst_CMD(HPS_SD_CMD),              //                               .hps_io_sdio_inst_CMD
               .hps_0_hps_io_hps_io_sdio_inst_D0(HPS_SD_DATA[0]),           //                               .hps_io_sdio_inst_D0
               .hps_0_hps_io_hps_io_sdio_inst_D1(HPS_SD_DATA[1]),           //                               .hps_io_sdio_inst_D1
               .hps_0_hps_io_hps_io_sdio_inst_CLK(HPS_SD_CLK),              //                               .hps_io_sdio_inst_CLK
               .hps_0_hps_io_hps_io_sdio_inst_D2(HPS_SD_DATA[2]),           //                               .hps_io_sdio_inst_D2
               .hps_0_hps_io_hps_io_sdio_inst_D3(HPS_SD_DATA[3]),           //                               .hps_io_sdio_inst_D3
               //HPS USB
               .hps_0_hps_io_hps_io_usb1_inst_D0(HPS_USB_DATA[0]),          //                               .hps_io_usb1_inst_D0
               .hps_0_hps_io_hps_io_usb1_inst_D1(HPS_USB_DATA[1]),          //                               .hps_io_usb1_inst_D1
               .hps_0_hps_io_hps_io_usb1_inst_D2(HPS_USB_DATA[2]),          //                               .hps_io_usb1_inst_D2
               .hps_0_hps_io_hps_io_usb1_inst_D3(HPS_USB_DATA[3]),          //                               .hps_io_usb1_inst_D3
               .hps_0_hps_io_hps_io_usb1_inst_D4(HPS_USB_DATA[4]),          //                               .hps_io_usb1_inst_D4
               .hps_0_hps_io_hps_io_usb1_inst_D5(HPS_USB_DATA[5]),          //                               .hps_io_usb1_inst_D5
               .hps_0_hps_io_hps_io_usb1_inst_D6(HPS_USB_DATA[6]),          //                               .hps_io_usb1_inst_D6
               .hps_0_hps_io_hps_io_usb1_inst_D7(HPS_USB_DATA[7]),          //                               .hps_io_usb1_inst_D7
               .hps_0_hps_io_hps_io_usb1_inst_CLK(HPS_USB_CLKOUT),          //                               .hps_io_usb1_inst_CLK
               .hps_0_hps_io_hps_io_usb1_inst_STP(HPS_USB_STP),             //                               .hps_io_usb1_inst_STP
               .hps_0_hps_io_hps_io_usb1_inst_DIR(HPS_USB_DIR),             //                               .hps_io_usb1_inst_DIR
               .hps_0_hps_io_hps_io_usb1_inst_NXT(HPS_USB_NXT),             //                               .hps_io_usb1_inst_NXT
               //HPS SPI
               .hps_0_hps_io_hps_io_spim1_inst_CLK(HPS_SPIM_CLK),           //                               .hps_io_spim1_inst_CLK
               .hps_0_hps_io_hps_io_spim1_inst_MOSI(HPS_SPIM_MOSI),         //                               .hps_io_spim1_inst_MOSI
               .hps_0_hps_io_hps_io_spim1_inst_MISO(HPS_SPIM_MISO),         //                               .hps_io_spim1_inst_MISO
               .hps_0_hps_io_hps_io_spim1_inst_SS0(HPS_SPIM_SS),            //                               .hps_io_spim1_inst_SS0
               //HPS UART
               .hps_0_hps_io_hps_io_uart0_inst_RX(HPS_UART_RX),             //                               .hps_io_uart0_inst_RX
               .hps_0_hps_io_hps_io_uart0_inst_TX(HPS_UART_TX),             //                               .hps_io_uart0_inst_TX
               //HPS I2C1
               .hps_0_hps_io_hps_io_i2c0_inst_SDA(HPS_I2C0_SDAT),           //                               .hps_io_i2c0_inst_SDA
               .hps_0_hps_io_hps_io_i2c0_inst_SCL(HPS_I2C0_SCLK),           //                               .hps_io_i2c0_inst_SCL
               //HPS I2C2
               .hps_0_hps_io_hps_io_i2c1_inst_SDA(HPS_I2C1_SDAT),           //                               .hps_io_i2c1_inst_SDA
               .hps_0_hps_io_hps_io_i2c1_inst_SCL(HPS_I2C1_SCLK),           //                               .hps_io_i2c1_inst_SCL
               //GPIO
               .hps_0_hps_io_hps_io_gpio_inst_GPIO09(HPS_CONV_USB_N),       //                               .hps_io_gpio_inst_GPIO09
               .hps_0_hps_io_hps_io_gpio_inst_GPIO35(HPS_ENET_INT_N),       //                               .hps_io_gpio_inst_GPIO35
               .hps_0_hps_io_hps_io_gpio_inst_GPIO40(HPS_LTC_GPIO),         //                               .hps_io_gpio_inst_GPIO40
               .hps_0_hps_io_hps_io_gpio_inst_GPIO53(HPS_LED),              //                               .hps_io_gpio_inst_GPIO53
               .hps_0_hps_io_hps_io_gpio_inst_GPIO54(HPS_KEY),              //                               .hps_io_gpio_inst_GPIO54
               .hps_0_hps_io_hps_io_gpio_inst_GPIO61(HPS_GSENSOR_INT),      //                               .hps_io_gpio_inst_GPIO61
               //FPGA Partion
               .led_pio_external_connection_export(fpga_led_internal),      //    led_pio_external_connection.export

  .sys_clk_clk        (                       ),
  .sys_rst_reset_n    (                       ),

  .str_out_endofpacket   ( str_endofpacket   ),
  .str_out_data          ( str_data          ),
  .str_out_empty         (                   ),
  .str_out_ready         ( str_ready         ),
  .str_out_startofpacket ( str_startofpacket ),
  .str_out_valid         ( str_valid_tmp     ),
  
  .system_0_str_0_data          ( str_data                ),
  .system_0_str_0_ready         ( str_ready_per_module[0] ),
  .system_0_str_0_valid         ( str_valid         ),
  .system_0_str_0_startofpacket ( str_startofpacket ),
  .system_0_str_0_endofpacket   ( str_endofpacket   ),
  
  .system_0_str_1_data          ( str_data          ),
  .system_0_str_1_ready         ( str_ready_per_module[1]                  ),
  .system_0_str_1_valid         ( str_valid         ),
  .system_0_str_1_startofpacket ( str_startofpacket ),
  .system_0_str_1_endofpacket   ( str_endofpacket   ),
  
  .system_0_str_2_data          ( str_data          ),
  .system_0_str_2_ready         ( str_ready_per_module[2] ),
  .system_0_str_2_valid         ( str_valid         ),
  .system_0_str_2_startofpacket ( str_startofpacket ),
  .system_0_str_2_endofpacket   ( str_endofpacket   ),

  .system_0_str_3_data          ( str_data          ),
  .system_0_str_3_ready         (  str_ready_per_module[3]                 ),
  .system_0_str_3_valid         ( str_valid         ),
  .system_0_str_3_startofpacket ( str_startofpacket ),
  .system_0_str_3_endofpacket   ( str_endofpacket   ),

  .system_0_str_4_data          ( str_data          ),
  .system_0_str_4_ready         ( str_ready_per_module[4]                  ),
  .system_0_str_4_valid         ( str_valid         ),
  .system_0_str_4_startofpacket ( str_startofpacket ),
  .system_0_str_4_endofpacket   ( str_endofpacket   ),

  .system_0_str_5_data          ( str_data          ),
  .system_0_str_5_ready         ( str_ready_per_module[5]                  ),
  .system_0_str_5_valid         ( str_valid         ),
  .system_0_str_5_startofpacket ( str_startofpacket ),
  .system_0_str_5_endofpacket   ( str_endofpacket   ),

  .system_0_str_6_data          ( str_data          ),
  .system_0_str_6_ready         ( str_ready_per_module[6]                  ),
  .system_0_str_6_valid         ( str_valid         ),
  .system_0_str_6_startofpacket ( str_startofpacket ),
  .system_0_str_6_endofpacket   ( str_endofpacket   ),

  .system_0_str_7_data          ( str_data          ),
  .system_0_str_7_ready         ( str_ready_per_module[7]                  ),
  .system_0_str_7_valid         ( str_valid         ),
  .system_0_str_7_startofpacket ( str_startofpacket ),
  .system_0_str_7_endofpacket   ( str_endofpacket   ),

  .system_0_str_8_data          ( str_data          ),
  .system_0_str_8_ready         ( str_ready_per_module[8]                  ),
  .system_0_str_8_valid         ( str_valid         ),
  .system_0_str_8_startofpacket ( str_startofpacket ),
  .system_0_str_8_endofpacket   ( str_endofpacket   ),

  .system_0_str_9_data          ( str_data          ),
  .system_0_str_9_ready         ( str_ready_per_module[9]                  ),
  .system_0_str_9_valid         ( str_valid         ),
  .system_0_str_9_startofpacket ( str_startofpacket ),
  .system_0_str_9_endofpacket   ( str_endofpacket   ),

  .system_0_str_10_data          ( str_data          ),
  .system_0_str_10_ready         ( str_ready_per_module[10]                  ),
  .system_0_str_10_valid         ( str_valid         ),
  .system_0_str_10_startofpacket ( str_startofpacket ),
  .system_0_str_10_endofpacket   ( str_endofpacket   ),

  .system_0_str_11_data          ( str_data          ),
  .system_0_str_11_ready         ( str_ready_per_module[11]                  ),
  .system_0_str_11_valid         ( str_valid         ),
  .system_0_str_11_startofpacket ( str_startofpacket ),
  .system_0_str_11_endofpacket   ( str_endofpacket   ),

  .system_0_str_12_data          ( str_data          ),
  .system_0_str_12_ready         ( str_ready_per_module[12]                  ),
  .system_0_str_12_valid         ( str_valid         ),
  .system_0_str_12_startofpacket ( str_startofpacket ),
  .system_0_str_12_endofpacket   ( str_endofpacket   ),

  .system_0_str_13_data          ( str_data          ),
  .system_0_str_13_ready         ( str_ready_per_module[13]                  ),
  .system_0_str_13_valid         ( str_valid         ),
  .system_0_str_13_startofpacket ( str_startofpacket ),
  .system_0_str_13_endofpacket   ( str_endofpacket   ),

  .system_0_str_14_data          ( str_data          ),
  .system_0_str_14_ready         ( str_ready_per_module[14]                  ),
  .system_0_str_14_valid         ( str_valid         ),
  .system_0_str_14_startofpacket ( str_startofpacket ),
  .system_0_str_14_endofpacket   ( str_endofpacket   ),

  .system_0_str_15_data          ( str_data          ),
  .system_0_str_15_ready         ( str_ready_per_module[15]                  ),
  .system_0_str_15_valid         ( str_valid         ),
  .system_0_str_15_startofpacket ( str_startofpacket ),
  .system_0_str_15_endofpacket   ( str_endofpacket   ),

  .system_0_str_16_data          ( str_data          ),
  .system_0_str_16_ready         ( str_ready_per_module[16]                  ),
  .system_0_str_16_valid         ( str_valid         ),
  .system_0_str_16_startofpacket ( str_startofpacket ),
  .system_0_str_16_endofpacket   ( str_endofpacket   ),

  .system_0_str_17_data          ( str_data          ),
  .system_0_str_17_ready         ( str_ready_per_module[17]                  ),
  .system_0_str_17_valid         ( str_valid         ),
  .system_0_str_17_startofpacket ( str_startofpacket ),
  .system_0_str_17_endofpacket   ( str_endofpacket   ),

  .system_0_str_18_data          ( str_data          ),
  .system_0_str_18_ready         ( str_ready_per_module[18]                  ),
  .system_0_str_18_valid         ( str_valid         ),
  .system_0_str_18_startofpacket ( str_startofpacket ),
  .system_0_str_18_endofpacket   ( str_endofpacket   ),

  .system_0_str_19_data          ( str_data          ),
  .system_0_str_19_ready         ( str_ready_per_module[19]                  ),
  .system_0_str_19_valid         ( str_valid         ),
  .system_0_str_19_startofpacket ( str_startofpacket ),
  .system_0_str_19_endofpacket   ( str_endofpacket   ),

  .system_0_str_20_data          ( str_data          ),
  .system_0_str_20_ready         ( str_ready_per_module[20]                  ),
  .system_0_str_20_valid         ( str_valid         ),
  .system_0_str_20_startofpacket ( str_startofpacket ),
  .system_0_str_20_endofpacket   ( str_endofpacket   ),

  .system_0_str_21_data          ( str_data          ),
  .system_0_str_21_ready         ( str_ready_per_module[21]                  ),
  .system_0_str_21_valid         ( str_valid         ),
  .system_0_str_21_startofpacket ( str_startofpacket ),
  .system_0_str_21_endofpacket   ( str_endofpacket   ),

  .system_0_str_22_data          ( str_data          ),
  .system_0_str_22_ready         ( str_ready_per_module[22]                  ),
  .system_0_str_22_valid         ( str_valid         ),
  .system_0_str_22_startofpacket ( str_startofpacket ),
  .system_0_str_22_endofpacket   ( str_endofpacket   ),

  .system_0_str_23_data          ( str_data          ),
  .system_0_str_23_ready         ( str_ready_per_module[23]                  ),
  .system_0_str_23_valid         ( str_valid         ),
  .system_0_str_23_startofpacket ( str_startofpacket ),
  .system_0_str_23_endofpacket   ( str_endofpacket   ),

  .system_0_str_24_data          ( str_data          ),
  .system_0_str_24_ready         ( str_ready_per_module[24]                  ),
  .system_0_str_24_valid         ( str_valid         ),
  .system_0_str_24_startofpacket ( str_startofpacket ),
  .system_0_str_24_endofpacket   ( str_endofpacket   ),


  .system_0_str_25_data          ( str_data          ),
  .system_0_str_25_ready         ( str_ready_per_module[25]                  ),
  .system_0_str_25_valid         ( str_valid         ),
  .system_0_str_25_startofpacket ( str_startofpacket ),
  .system_0_str_25_endofpacket   ( str_endofpacket   ),

  .system_0_str_26_data          ( str_data          ),
  .system_0_str_26_ready         ( str_ready_per_module[26]                  ),
  .system_0_str_26_valid         ( str_valid         ),
  .system_0_str_26_startofpacket ( str_startofpacket ),
  .system_0_str_26_endofpacket   ( str_endofpacket   ),

  .system_0_str_27_data          ( str_data          ),
  .system_0_str_27_ready         ( str_ready_per_module[27]                  ),
  .system_0_str_27_valid         ( str_valid         ),
  .system_0_str_27_startofpacket ( str_startofpacket ),
  .system_0_str_27_endofpacket   ( str_endofpacket   ),

  .system_0_str_28_data          ( str_data          ),
  .system_0_str_28_ready         ( str_ready_per_module[28]                  ),
  .system_0_str_28_valid         ( str_valid         ),
  .system_0_str_28_startofpacket ( str_startofpacket ),
  .system_0_str_28_endofpacket   ( str_endofpacket   ),

  .system_0_str_29_data          ( str_data          ),
  .system_0_str_29_ready         ( str_ready_per_module[29]                  ),
  .system_0_str_29_valid         ( str_valid         ),
  .system_0_str_29_startofpacket ( str_startofpacket ),
  .system_0_str_29_endofpacket   ( str_endofpacket   ),

  .system_0_str_30_data          ( str_data          ),
  .system_0_str_30_ready         ( str_ready_per_module[30]                  ),
  .system_0_str_30_valid         ( str_valid         ),
  .system_0_str_30_startofpacket ( str_startofpacket ),
  .system_0_str_30_endofpacket   ( str_endofpacket   ),

  .system_0_str_31_data          ( str_data          ),
  .system_0_str_31_ready         ( str_ready_per_module[31]                  ),
  .system_0_str_31_valid         ( str_valid         ),
  .system_0_str_31_startofpacket ( str_startofpacket ),
  .system_0_str_31_endofpacket   ( str_endofpacket   )
  
);

assign str_ready = &( str_ready_per_module );
assign str_valid = str_ready && str_valid_tmp;

assign LED[0] = 1'b1;

sjtag #(
  .ENABLE_JTAG_IO_SELECTION  ( 1                     )
	) sj (
  .tms                 ( gpio4                 ),
  .tdi                 ( gpio8                 ),
  .tdo                 ( gpio2                 ),
  .tck                 ( gpio0                 ),
  .select_this         ( 1'b1                  )
	);

assign gpio1 = 1'b0; 
assign gpio3 = 1'b1; 
assign gpio9 = 1'b0; 


assign gpio5 = 1'b0; 
assign gpio6 = 1'b0; 
assign gpio7 = 1'b0; 

endmodule
