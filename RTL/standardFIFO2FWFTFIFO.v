/*
 * @Author       : Xu Xiaokang
 * @Email        : xuxiaokang_up@qq.com
 * @Date         : 2023-09-15 21:48:18
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2023-09-16 15:19:55
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: 将Standard FIFO的读端口转换为FWFT(First Word Fall Through) FIFO的读端口
!         (在Quartus中, Standard FIFO被称为Noraml FIFO, FWFT FIFO被称为Show-ahead FIFO)
* 思路:
  标准FIFO的读端口要变为FWFT FIFO的读端口, 两者的区别在于:
  Noraml FIFO的dout在empty为低时, 数据还不是新数据, 而是在rd_en有效后再延迟更新
  而FWFT FIFO的dout在empty为低时, 数据就已经是新数据, 在rd_en有效后立即更新下一个数据
1.直连两种FIFO的dout, 通过改变empty信号来指示数据是否有效
2.标准FIFO非空, 马上读数据, 模拟FWFT FIFO的dout行为; FWFT FIFO的rd_en使能, 标准FIFO如果非空则同步使能, 更新下一个数据
3.FWFT的empty信号在数据更新完成后拉低, 在数据更新过程中拉高 或 在读出最后一个数据后拉高
4.在FIFO复位时, 拉高fwft_fifo_empty
~ 使用:
1.READ_LATENCY = 0视为FIFO本身就是FWFT FIFO, 此时信号直连, 无任何操作
2.对于Standard FIFO, READ_LATENCY最小为1, 此时本模块可完全将Standard FIFO的读端口转为FWFT FIFO的读端口, 与真实的FWFT FIFO完全相同
3.对于READ_LATENCY大于等于2的情况, 因为读延迟影响, Standard FIFO的数据在连续读的过程中, 有效数据之间必然存在间隔, 所以, 此时本模块
  无法完全模拟FWFT FIFO, fwft_fifo_empty会间歇性拉高, 无法一直为低, 因为有效数据无法连续更新。
*/

`default_nettype none

module standardFIFO2FWFTFIFO
#(
  // 1(默认)表示在rd_en有效后, 标准FIFO立刻更新数据; 2表示在rd_en有效后, 标准FIFO延迟一个读时钟再更新数据
  parameter STANDARD_FIFO_READ_LATENCY = 1,
  parameter STANDARD_FIFO_DOUT_WIDTH = 8 // FIFO输出端口数据位宽
)(
  output wire [STANDARD_FIFO_DOUT_WIDTH-1 : 0] fwft_fifo_dout,
  output reg                                   fwft_fifo_empty,
  input  wire                                  fwft_fifo_rd_en,

  input  wire [STANDARD_FIFO_DOUT_WIDTH-1 : 0] standard_fifo_dout,
  input  wire                                  standard_fifo_empty,
  output wire                                  standard_fifo_rd_en,

  input  wire clk, // 此时钟必须也是FIFO的读时钟
  input  wire srst // 读端口同步复位, 高电平有效(与Xilinx FIFO复位电平保持一致)
);


assign fwft_fifo_dout = standard_fifo_dout;


generate
if (STANDARD_FIFO_READ_LATENCY == 0) begin
  always @(*) begin
    fwft_fifo_empty = standard_fifo_empty;
  end

  assign standard_fifo_rd_en = fwft_fifo_rd_en;
end
else if (STANDARD_FIFO_READ_LATENCY == 1)  begin
  reg standard_fifo_empty_r1;
  always @(posedge clk) begin
    standard_fifo_empty_r1 <= standard_fifo_empty;
  end

  wire standard_fifo_empty_nedge = ~standard_fifo_empty && standard_fifo_empty_r1;

  assign standard_fifo_rd_en = standard_fifo_empty_nedge || (~standard_fifo_empty && fwft_fifo_rd_en);

  always @(posedge clk) begin
    if (srst)
      fwft_fifo_empty <= 1'b1;
    else if (standard_fifo_rd_en)
      fwft_fifo_empty <= 1'b0;
    else if (fwft_fifo_rd_en && standard_fifo_empty)
      fwft_fifo_empty <= 1'b1;
    else
      fwft_fifo_empty <= fwft_fifo_empty;
  end
end
else begin
  reg standard_fifo_empty_r1;
  always @(posedge clk) begin
    standard_fifo_empty_r1 <= standard_fifo_empty;
  end

  wire standard_fifo_empty_nedge = ~standard_fifo_empty && standard_fifo_empty_r1;

  assign standard_fifo_rd_en = standard_fifo_empty_nedge || (~standard_fifo_empty && fwft_fifo_rd_en);

  localparam READ_LATENCY_CNT_MAX = STANDARD_FIFO_READ_LATENCY-1;
  reg [$clog2(READ_LATENCY_CNT_MAX+1)-1 : 0] read_latency_cnt;
  always @(posedge clk) begin
    if (standard_fifo_rd_en)
      read_latency_cnt <= READ_LATENCY_CNT_MAX;
    else if (read_latency_cnt > 0)
      read_latency_cnt <= read_latency_cnt - 1'b1;
    else
      read_latency_cnt <= 'd0;
  end

  always @(posedge clk) begin
    if (srst)
      fwft_fifo_empty <= 1'b1;
    else if (standard_fifo_rd_en)
      fwft_fifo_empty <= 1'b1;
    else if (read_latency_cnt == 'd1)
      fwft_fifo_empty <= 1'b0;
    else if (fwft_fifo_rd_en && standard_fifo_empty)
      fwft_fifo_empty <= 1'b1;
    else
      fwft_fifo_empty <= fwft_fifo_empty;
  end
end
endgenerate


endmodule
`resetall