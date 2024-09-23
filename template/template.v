/*
 * @Author       : Xu Xiaokang
 * @Email        : xuxiaokang_up@qq.com
 * @Date         : 2024-09-14 11:40:11
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2024-09-23 22:24:00
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: 标准FIFO转FWFT FIFO实例化参考
*/


standardFIFO2FWFTFIFO #(
  // 1(默认)表示在rd_en有效后, 标准FIFO立刻更新数据; 2表示在rd_en有效后, 标准FIFO延迟一个读时钟再更新数据
  .STANDARD_FIFO_READ_LATENCY (1),
  .STANDARD_FIFO_DOUT_WIDTH   (STANDARD_FIFO_DOUT_WIDTH) // FIFO输出端口数据位宽
) standardFIFO2FWFTFIFO_u0 (
  .fwft_fifo_dout      (fwft_fifo_dout     ),
  .fwft_fifo_empty     (fwft_fifo_empty    ),
  .fwft_fifo_rd_en     (fwft_fifo_rd_en    ),
  .standard_fifo_dout  (standard_fifo_dout ),
  .standard_fifo_empty (standard_fifo_empty),
  .standard_fifo_rd_en (standard_fifo_rd_en),
  .clk                 (clk                ),
  .srst                (srst               )
);