module standardFIFO2FWFTFIFO_tb();

timeunit 1ns;
timeprecision 10ps;

localparam STANDARD_FIFO_DIN_WDITH    = 8;
localparam STANDARD_FIFO_READ_LATENCY = 2;
localparam STANDARD_FIFO_DOUT_WIDTH   = 8;

logic [STANDARD_FIFO_DIN_WDITH-1:0] din;
logic                 wr_en;
logic                 full;

logic fwft_fifo_empty;
logic fwft_fifo_rd_en;

logic true_fwft_fifo_empty;
logic true_fwft_fifo_rd_en;

logic clk;
logic rstn;

standardFIFO2FWFTFIFOTop #(
  .STANDARD_FIFO_DIN_WDITH    (STANDARD_FIFO_DIN_WDITH   ),
  .STANDARD_FIFO_READ_LATENCY (STANDARD_FIFO_READ_LATENCY),
  .STANDARD_FIFO_DOUT_WIDTH   (STANDARD_FIFO_DOUT_WIDTH)
)  standardFIFO2FWFTFIFOTop_inst(.*);


// 生成时钟
localparam CLKT = 2;
initial begin
  clk = 0;
  forever #(CLKT / 2) clk = ~clk;
end


initial begin
  rstn = 0;
  wr_en = 1'b0;
  #(CLKT * 10)  rstn = 1;
  #(CLKT * 10);

  // 一次写入一个数据
  wr_en = 1'b1;
  #(CLKT) wr_en = 1'b0;

  #(CLKT*5)
  // 一次写入一个数据
  wr_en = 1'b1;
  #(CLKT) wr_en = 1'b0;

  #(CLKT*5)
  // 一次写入多个数据
  wr_en = 1'b1;
  #(CLKT*3) wr_en = 1'b0;

  #(CLKT*1)
  // 一次写入单个数据
  wr_en = 1'b1;
  #(CLKT) wr_en = 1'b0;

  #(CLKT * 30) $stop;
end


always_ff @(posedge clk) begin
  if (~rstn)
    din <= 'd0;
  else
    din <= din + 1;
end


localparam CLK_CNT_MAX = 4;
logic [$clog2(CLK_CNT_MAX+1)-1 : 0] clk_cnt;
always_ff @(posedge clk, negedge rstn) begin
  if (~rstn)
    clk_cnt <= '0;
  else if (clk_cnt < CLK_CNT_MAX)
    clk_cnt <= clk_cnt + 1'b1;
  else
    clk_cnt <= '0;
end


assign fwft_fifo_rd_en = ~fwft_fifo_empty && clk_cnt == CLK_CNT_MAX;

assign true_fwft_fifo_rd_en = ~true_fwft_fifo_empty && clk_cnt == CLK_CNT_MAX;


endmodule