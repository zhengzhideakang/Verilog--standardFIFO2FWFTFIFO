/*
 * @Author       : Xu Xiaokang
 * @Email        : xuxiaokang_up@qq.com
 * @Date         : 2023-09-15 22:55:13
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2023-09-16 15:21:59
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: 顶层文件, 实例化模块和两种类型的FIFO, 给相同输入, 判断读端口的输出行为是否一致
* 思路:
  1.
*/



module standardFIFO2FWFTFIFOTop
#(
  parameter STANDARD_FIFO_DIN_WDITH    = 8,
  parameter STANDARD_FIFO_READ_LATENCY = 1,
  parameter STANDARD_FIFO_DOUT_WIDTH   = 8
)(
  input  wire [STANDARD_FIFO_DIN_WDITH-1:0] din,
  input  wire                               wr_en,
  output wire                               full,

  output wire fwft_fifo_empty,
  input  wire fwft_fifo_rd_en,

  output wire true_fwft_fifo_empty,
  input  wire true_fwft_fifo_rd_en,

  input  wire clk,
  input  wire rstn
);




//++ 实例化读端口转换模块 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire [STANDARD_FIFO_DOUT_WIDTH-1 : 0] fwft_fifo_dout;

wire [STANDARD_FIFO_DOUT_WIDTH-1 : 0] standard_fifo_dout;
wire                                  standard_fifo_empty;
wire                                  standard_fifo_rd_en;


standardFIFO2FWFTFIFO #(
  .STANDARD_FIFO_READ_LATENCY(STANDARD_FIFO_READ_LATENCY),
  .STANDARD_FIFO_DOUT_WIDTH  (STANDARD_FIFO_DOUT_WIDTH)
) standardFIFO2FWFTFIFO_inst (
  .fwft_fifo_dout      (fwft_fifo_dout     ),
  .fwft_fifo_empty     (fwft_fifo_empty    ),
  .fwft_fifo_rd_en     (fwft_fifo_rd_en    ),
  .standard_fifo_dout  (standard_fifo_dout ),
  .standard_fifo_empty (standard_fifo_empty),
  .standard_fifo_rd_en (standard_fifo_rd_en),
  .clk                 (clk                ),
  .srst                (~rstn              )
);
//-- 实例化读端口转换模块 ------------------------------------------------------------


//++ 实例化两种FIFO ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire [STANDARD_FIFO_DOUT_WIDTH-1 : 0] true_fwft_fifo_dout;

FWFTFIFO FWFTFIFO_u0 (
  .din   (din  ), // input wire [7 : 0] din
  .wr_en (wr_en), // input wire wr_en
  .full  (full ), // output wire full

  .dout  (true_fwft_fifo_dout ), // output wire [7: 0] dout
  .empty (true_fwft_fifo_empty),  // output wire empty
  .rd_en (true_fwft_fifo_rd_en), // input wire rd_en

  .clk   (clk  ), // input wire clk
  .srst  (~rstn) // input wire srst
);


standardFIFO standardFIFO_u0 (
  .din   (din  ), // input wire [7 : 0] din
  .wr_en (wr_en), // input wire wr_en
  .full  (full ), // output wire full

  .dout  (standard_fifo_dout ), // output wire [7: 0] dout
  .empty (standard_fifo_empty), // output wire empty
  .rd_en (standard_fifo_rd_en), // input wire rd_en

  .clk   (clk  ), // input wire clk
  .srst  (~rstn) // input wire srst
);
//-- 实例化两种FIFO ------------------------------------------------------------



endmodule