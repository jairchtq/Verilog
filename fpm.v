module fpm(
    input [1:0] ram_addr_juiz ,
    output [31:0] ram_out_juiz ,
    output reg done
    );

    // Variaveis da ROM e RAM
    reg  [2:0]  rom_addr ;
    reg  [1:0]  ram_addr ;
    wire [31:0] rom_out , ram_in ;
    reg         ram_RW , rom_OE , ram_OE ;

    // Variaveis do multiplicador
    reg  [31:0] mul_a , mul_b ;
    reg         mul_en , mul_rst , mul_clk =0;
    wire        mul_done ;
    wire [31:0] mul_z ;

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
    done =1'b0;
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