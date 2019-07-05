
//ͨ�üĴ�������32��
`include "defines.v"

module regfile(

	input wire clk,
	input wire	rst,
	
	//д�˿�
	input wire we,
	//дʹ���źţ�ֻ�д�����Ϊ1���Ĵ����Ž����޸�����
	input wire[`RegAddrBus] waddr,
	input wire[`RegBus] wdata,
	
	//���˿�1
	input wire re1,
	//��һ�����˿��Ƿ�ɶ�
	input wire[`RegAddrBus] raddr1,
	//Ҫ���ļĴ�����ַ
	output reg[`RegBus] rdata1,
	//��ȡ������
	
	//���˿�2
	input wire re2,
	input wire[`RegAddrBus]			  raddr2,
	output reg[`RegBus]           rdata2
	
);

	reg[`RegBus]  regs[0:`RegNum-1];

	always @ (posedge clk) begin
		if (rst == `RstDisable) 
		begin
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	//���ӿ�1
	always @ (*) begin
		if(rst == `RstEnable) begin	//��λ
			  rdata1 <= `ZeroWord;
	  end else if(raddr1 == `RegNumLog2'h0) begin	
			//ȡ$0ʱ��ֱ�Ӹ���0
	  		rdata1 <= `ZeroWord;
	  end else if((raddr1 == waddr) && (we == `WriteEnable) 
	  	            && (re1 == `ReadEnable)) begin
		  //���д��ͬʱ�������ҿɶ���д��ֱ�ӷ���Ҫд������
		  //�˴����RAW���ݳ�ͻ�����2��ָ��ģ�
	  	  rdata1 <= wdata;
	  end else if(re1 == `ReadEnable) begin
		  //��ͨ�ɶ�����£���ȡ�Ĵ���
	      rdata1 <= regs[raddr1];
	  end else begin
		  //���������ֱ�ӷ���0
	      rdata1 <= `ZeroWord;
	  end
	end

	//���ӿ�2
	//�˽ӿ�������Ķ��ӿ�����
	always @ (*) begin
		if(rst == `RstEnable) begin
			  rdata2 <= `ZeroWord;
	  end else if(raddr2 == `RegNumLog2'h0) begin
	  		rdata2 <= `ZeroWord;
	  end else if((raddr2 == waddr) && (we == `WriteEnable) 
	  	            && (re2 == `ReadEnable)) begin
	  	  rdata2 <= wdata;
	  end else if(re2 == `ReadEnable) begin
	      rdata2 <= regs[raddr2];
	  end else begin
	      rdata2 <= `ZeroWord;
	  end
	end

endmodule