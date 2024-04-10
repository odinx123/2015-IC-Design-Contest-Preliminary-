module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

	input clk, rst;
	input en;
	input [23:0] central;
	input [11:0] radius;
	input [1:0] mode;
	output reg busy;
	output reg valid;
	output reg [7:0] candidate;
	
	reg [3:0]X,Y;

	reg [1:0]state,nextstate;
	parameter IDLE = 2'b00, BUSY = 2'b01, OUTPUT=2'b10 ;

	always@(negedge clk,posedge rst)begin
		if(rst)
			state<=IDLE;
		else
			state<=nextstate;
	end

	always@(*)begin
		case(state)
			IDLE:begin
				if(en)nextstate=BUSY;
				else nextstate=IDLE;
			end
			BUSY:begin
				if(Y<9)nextstate=BUSY;
				else nextstate= OUTPUT;
			end
			OUTPUT:begin
				nextstate=IDLE;
			end
			default: nextstate=IDLE;
		endcase
	end

	reg[11:0] r;
	reg[23:0] c;
	wire [7:0]tx,ty,tr,tx2,ty2,tr2,tx3,ty3,tr3;
	assign tx=(X-c[23:20])*(X-c[23:20]);
	assign ty=(Y - c[19:16])* (Y-c[19:16]);
	assign tr=r[11:8]*r[11:8];
	
	assign tx2=(X-c[15:12])*(X-c[15:12]);
	assign ty2=(Y - c[11:8])* (Y-c[11:8]);
	assign tr2=r[7:4]*r[7:4];
	
	assign tx3=(X-c[7:4])*(X-c[7:4]);
	assign ty3=(Y - c[3:0])* (Y-c[3:0]);
	assign tr3=r[3:0]*r[3:0];
	
	wire A_c, B_c, C_c;
	wire isInside;
	
	assign A_c = tx + ty <= tr;
	assign B_c = tx2 + ty2 <= tr2;
	assign C_c = tx3 + ty3 <= tr3;
	assign isInside = Y != 9;

	always@(negedge clk , posedge rst)begin
		if(rst)begin
				busy <= 1'b0;
				valid <= 1'b0;
				candidate <= 8'd0;
				X <= 0;
				Y <= 0;
				r <= 0;
				c <=0;
		end
		else begin
			case(state)
				IDLE:begin
					busy <= 1'b0;
					valid <= 1'b0;
					candidate <= 8'd0;
					X <= 5'd1;
					Y <= 5'd1;
					r <= radius;
					c <= central;
				end
				BUSY:begin
					busy <= 1'b1;
					case(mode)
						2'b00:begin  // A set
							if(A_c & isInside)
								candidate <= candidate+1'b1;
						end
						2'b01:begin
							if(A_c & B_c & isInside)
								candidate <= candidate+1'b1;
						end
						2'b10:begin
							if( (A_c ^ B_c) & isInside)
								candidate <= candidate+1'b1;
						end
						2'b11:begin
							if( ~(A_c ^ B_c ^ C_c) & (A_c | B_c | C_c ) & isInside)
								candidate <= candidate+1'b1;
						end
						
					endcase
					if(X==8)begin
						Y<=Y+1;
						X<=1;
					end
					else
						X <= X+1'b1;
				end
				OUTPUT:begin
					valid <= 1'b1;
				end
			endcase
		end
	end

endmodule
