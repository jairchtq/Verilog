module rom_8 (
    input [2:0] addr,
    input OE,
    output reg [31:0] out
);
    reg [31:0] data[7:0];
    initial
    begin
        data [0] = 32'h0986ab68;
        data [1] = 32'h10385ba9;
        data [2] = 32'b00111111100000000000000000000000; // 1         32'h3f800000;
        data [3] = 32'b00111110100000000000000000000000; // 0.25      32'h3e800000;
        data [4] = 32'b01000000010000000000000000000000; // 3         32'h40400000;
        data [5] = 32'b01000001001000000000000000000000; // 10        32'h41200000;
        data [6] = 32'b00111110101000000000000000000000; // 0.3125    32'h3ea00000;
        data [7] = 32'b00111111011000000000000000000000; // 0.875     32'h3f600000;
    end
    always @(addr, OE)
        if (OE==1'b1)
            out=data[addr];
        else
            out=32'bz;
endmodule

module ram_4(
    input [31:0] in,
    input [1:0] addr,
    input RW, OE,
    output reg [31:0] out
);
    reg [31:0] data[3:0];
    always @(in, addr, RW, OE)
    begin
        if(RW==1'b0 & OE==1'b1)
            out=data[addr];
        else
            out=32'bz;
        if(RW==1'b1)
        data[addr]=in;
    end
endmodule


module fpa(
    input [1:0] ram_addr_juiz ,
    output reg [31:0] ram_out_juiz ,
    output reg done
    );

    // Variaveis da ROM e RAM
    reg  [2:0]  rom_addr;
    reg  [1:0]  ram_addr;
    wire [31:0] rom_out, ram_in;
    reg ram_RW, rom_OE, ram_OE;

    // Variaveis do multiplicador
    reg [31:0] mul_a , mul_b;
    reg mul_en , mul_rst , mul_clk = 0;
    wire mul_done;
    wire [31:0] mul_z;

    // Clock para o multiplicador
    always
        #1 mul_clk = ~mul_clk ;

    // Multiplexador para o juiz
    wire [1:0] ram_addr_mux ;
    assign ram_addr_mux = ( ram_RW ? ram_addr : ram_addr_juiz );

	rom_8 rom(
		.addr(rom_addr),
		.OE(rom_OE),
		.out(rom_out)
	);


    ram_4 ram(
        .in(ram_in),
        .addr(ram_addr_mux),
        .RW(ram_RW),
        .OE(ram_OE),
        .out(ram_out_juiz)
    );

    fp_mult multiplicador(
        .input_a(mul_a),
        .input_b(mul_b),
        .en(mul_en),
        .rst(mul_rst),
        .clk(mul_clk),
        .done(mul_done),
        .output_z(mul_z)
    );
    
    integer i;
    // reg [31:0] resultado;
    assign ram_in = mul_z;
    
    initial begin
      done = 1'b0;
      rom_OE = 1'b1;
      ram_OE = 1'b1;
      ram_RW = 1'b1;
      #5
      for (i = 0; i < 4; i = i + 1) begin
        mul_rst = 1'b0;
        mul_en = 0;
        ram_addr = i;
        rom_addr = 2*i; #1;
        mul_a = rom_out; #1;
        rom_addr = 2*i+1; #1;
        mul_b = rom_out; #1;
        mul_en = 1'b1;
        // resultado = mul_z;
        while (mul_done !== 1) #1;
        mul_rst = 1'b1;
        #3;
      end
      ram_RW = 1'b0;
      done = 1'b1;      
    end
    
    
endmodule