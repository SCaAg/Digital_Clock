module tb_bcd_adder;
  reg [3:0] a;
  reg [3:0] b;
  reg cin;
  wire [3:0] sum;
  wire cout;

  // Instantiate the BCD adder module
  bcd_adder uut (
      .a(a),
      .b(b),
      .cin(cin),
      .sum(sum),
      .cout(cout)
  );

  initial begin
    // Test case 1: 5 + 3 = 8 (no carry)
    a   = 4'b0101;
    b   = 4'b0011;
    cin = 0;
    #10;
    $display("Test Case 1: a = %d, b = %d, cin = %d -> sum = %d, cout = %d", a, b, cin, sum, cout);

    // Test case 2: 7 + 6 = 13 (requires adjustment)
    a   = 4'b0111;
    b   = 4'b0110;
    cin = 0;
    #10;
    $display("Test Case 2: a = %d, b = %d, cin = %d -> sum = %d, cout = %d", a, b, cin, sum, cout);

    // Test case 3: 9 + 9 + 1 = 19 (requires adjustment, with carry in)
    a   = 4'b1001;
    b   = 4'b1001;
    cin = 1;
    #10;
    $display("Test Case 3: a = %d, b = %d, cin = %d -> sum = %d, cout = %d", a, b, cin, sum, cout);

    // Test case 4: 0 + 0 = 0 (no carry)
    a   = 4'b0000;
    b   = 4'b0000;
    cin = 0;
    #10;
    $display("Test Case 4: a = %d, b = %d, cin = %d -> sum = %d, cout = %d", a, b, cin, sum, cout);

    // Test case 5: 8 + 2 = 10 (requires adjustment)
    a   = 4'b1000;
    b   = 4'b0010;
    cin = 0;
    #10;
    $display("Test Case 5: a = %d, b = %d, cin = %d -> sum = %d, cout = %d", a, b, cin, sum, cout);

    // End of simulation
    $stop;
  end
endmodule
