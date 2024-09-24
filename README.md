# Verilog功能模块--标准FIFO转首字直通FIFO

Gitee与Github同步：

[Verilog功能模块--标准FIFO转首字直通FIFO: Verilog功能模块--标准FIFO转首字直通FIFO (gitee.com)](https://gitee.com/xuxiaokang/verilog-function-module--standardFIFO2FWFTFIFO)

[zhengzhideakang/Verilog--standardFIFO2FWFTFIFO: Verilog功能模块--标准FIFO转首字直通FIFO (github.com)](https://github.com/zhengzhideakang/Verilog--standardFIFO2FWFTFIFO)

## 简介

在使用FIFO IP核时，我更喜欢使用FWFT(First Word First Through) FIFO而非标准FIFO，FWFT FIFO的数据会预先加载到dout端口，当empty为低时数据就已经有效了，而rd_en信号是指示此FIFO更新下一个数据，这种FWFT FIFO的读取延时是0。无需关心读延时使得读端口的控制变得非常简单，所以，我自编的一些模块均使用了FWFT FIFO的读端口作为接口。

但是，最近我开始使用国产的FPGA，安路的EG4系列，对应的开发工具TD（TangDanasty）中的FIFO只有Stardard FIFO这一种，并没有提供FWFT FIFO的选项，如果将标准FIFO读端口与以FWFT FIFO读端口为端口的模块连接，原本正常工作的模块逻辑就会出问题。

因此，我设计了一个标准FIFO读端口转FWFT FIFO读端口的模块，名为standardFIFO2FWFTFIFO.v，通过此模块能将Stardard FIFO读端口转为FWFT FIFO读端口，转换后端口的行为与真实的FWFT FIFO读端口完全一致。

## 模块框图

![standardFIFO2FWFTFIFO](https://picgo-dakang.oss-cn-hangzhou.aliyuncs.com/img/standardFIFO2FWFTFIFO.svg)

## 更多请参考

[Verilog功能模块——标准FIFO转FWFT FIFO – 徐晓康的博客 (myhardware.top)](https://www.myhardware.top/verilog功能模块-标准fifo转fwft-fifo/)

