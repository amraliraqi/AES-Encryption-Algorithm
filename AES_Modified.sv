module aes_modified (
	input clk, rst,
	input start,
	input [127:0] in, encrypkey,
	output reg [127:0] out);

	reg [7:0] plaintext [0:3] [0:3];
	reg [7:0] key [0:3] [0:3];
	reg [7:0] s_box [0:15] [0:15];
	reg [7:0] rijandael [0:3] [0:3];
	reg [7:0] rcon [0:3] [0:9];
	reg [7:0] mem_reg [0:3] [0:3];
	reg [7:0] mem_next [0:3] [0:3];
	reg[4:0] counter_reg, counter_next=0;
	reg [7:0] mem_temp [0:3];
	reg [7:0] mem_temp_2 [0:3];

	reg [2:0] state_current, state_next;
	localparam IDLE=3'b000;
	localparam ROUND_INI=3'b001;
	localparam SUBBYTES=3'b010;
	localparam SHIFTROW=3'b011;
	localparam MIXCOL=3'b100;
	localparam ROUNDKEY=3'b101;
	localparam RESULT=3'b110;

	integer i, j;
	integer z;
	always @(posedge clk or posedge rst)
		if (rst) begin
			z=0;
			state_current<=IDLE;
			counter_reg<=0;
			for(i=0;i<4;i=i+1) 
				for(j=0;j<4;j=j+1) begin
					plaintext[i][j]<=in[127 - 8*z -: 8];
					key[i][j]<=encrypkey[127 - 8*z -: 8];
					mem_reg[i][j]<=0;
					z=z+1;
				end	

			s_box[0][0] <= 8'h63; s_box[0][1] <= 8'h7c; s_box[0][2] <= 8'h77; s_box[0][3] <= 8'h7b;
			s_box[0][4] <= 8'hf2; s_box[0][5] <= 8'h6b; s_box[0][6] <= 8'h6f; s_box[0][7] <= 8'hc5;
			s_box[0][8] <= 8'h30; s_box[0][9] <= 8'h01; s_box[0][10] <= 8'h67; s_box[0][11] <= 8'h2b;
			s_box[0][12] <= 8'hfe; s_box[0][13] <= 8'hd7; s_box[0][14] <= 8'hab; s_box[0][15] <= 8'h76;

			s_box[1][0] <= 8'hca; s_box[1][1] <= 8'h82; s_box[1][2] <= 8'hc9; s_box[1][3] <= 8'h7d;
			s_box[1][4] <= 8'hfa; s_box[1][5] <= 8'h59; s_box[1][6] <= 8'h47; s_box[1][7] <= 8'hf0;
			s_box[1][8] <= 8'had; s_box[1][9] <= 8'hd4; s_box[1][10] <= 8'ha2; s_box[1][11] <= 8'haf;
			s_box[1][12] <= 8'h9c; s_box[1][13] <= 8'ha4; s_box[1][14] <= 8'h72; s_box[1][15] <= 8'hc0;

			s_box[2][0] <= 8'hb7; s_box[2][1] <= 8'hfd; s_box[2][2] <= 8'h93; s_box[2][3] <= 8'h26;
			s_box[2][4] <= 8'h36; s_box[2][5] <= 8'h3f; s_box[2][6] <= 8'hf7; s_box[2][7] <= 8'hcc;
			s_box[2][8] <= 8'h34; s_box[2][9] <= 8'ha5; s_box[2][10] <= 8'he5; s_box[2][11] <= 8'hf1;
			s_box[2][12] <= 8'h71; s_box[2][13] <= 8'hd8; s_box[2][14] <= 8'h31; s_box[2][15] <= 8'h15;

			s_box[3][0] <= 8'h04; s_box[3][1] <= 8'hc7; s_box[3][2] <= 8'h23; s_box[3][3] <= 8'hc3;
			s_box[3][4] <= 8'h18; s_box[3][5] <= 8'h96; s_box[3][6] <= 8'h05; s_box[3][7] <= 8'h9a;
			s_box[3][8] <= 8'h07; s_box[3][9] <= 8'h12; s_box[3][10] <= 8'h80; s_box[3][11] <= 8'he2;
			s_box[3][12] <= 8'heb; s_box[3][13] <= 8'h27; s_box[3][14] <= 8'hb2; s_box[3][15] <= 8'h75;

			s_box[4][0] <= 8'h09; s_box[4][1] <= 8'h83; s_box[4][2] <= 8'h2c; s_box[4][3] <= 8'h1a;
			s_box[4][4] <= 8'h1b; s_box[4][5] <= 8'h6e; s_box[4][6] <= 8'h5a; s_box[4][7] <= 8'ha0;
			s_box[4][8] <= 8'h52; s_box[4][9] <= 8'h3b; s_box[4][10] <= 8'hd6; s_box[4][11] <= 8'hb3;
			s_box[4][12] <= 8'h29; s_box[4][13] <= 8'he3; s_box[4][14] <= 8'h2f; s_box[4][15] <= 8'h84;

			s_box[5][0] <= 8'h53; s_box[5][1] <= 8'hd1; s_box[5][2] <= 8'h00; s_box[5][3] <= 8'hed;
			s_box[5][4] <= 8'h20; s_box[5][5] <= 8'hfc; s_box[5][6] <= 8'hb1; s_box[5][7] <= 8'h5b;
			s_box[5][8] <= 8'h6a; s_box[5][9] <= 8'hcb; s_box[5][10] <= 8'hbe; s_box[5][11] <= 8'h39;
			s_box[5][12] <= 8'h4a; s_box[5][13] <= 8'h4c; s_box[5][14] <= 8'h58; s_box[5][15] <= 8'hcf;

			s_box[6][0] <= 8'hd0; s_box[6][1] <= 8'hef; s_box[6][2] <= 8'haa; s_box[6][3] <= 8'hfb;
			s_box[6][4] <= 8'h43; s_box[6][5] <= 8'h4d; s_box[6][6] <= 8'h33; s_box[6][7] <= 8'h85;
			s_box[6][8] <= 8'h45; s_box[6][9] <= 8'hf9; s_box[6][10] <= 8'h02; s_box[6][11] <= 8'h7f;
			s_box[6][12] <= 8'h50; s_box[6][13] <= 8'h3c; s_box[6][14] <= 8'h9f; s_box[6][15] <= 8'ha8;

			s_box[7][0] <= 8'h51; s_box[7][1] <= 8'ha3; s_box[7][2] <= 8'h40; s_box[7][3] <= 8'h8f;
			s_box[7][4] <= 8'h92; s_box[7][5] <= 8'h9d; s_box[7][6] <= 8'h38; s_box[7][7] <= 8'hf5;
			s_box[7][8] <= 8'hbc; s_box[7][9] <= 8'hb6; s_box[7][10] <= 8'hda; s_box[7][11] <= 8'h21;
			s_box[7][12] <= 8'h10; s_box[7][13] <= 8'hff; s_box[7][14] <= 8'hf3; s_box[7][15] <= 8'hd2;

			s_box[8][0] <= 8'hcd; s_box[8][1] <= 8'h0c; s_box[8][2] <= 8'h13; s_box[8][3] <= 8'hec;
			s_box[8][4] <= 8'h5f; s_box[8][5] <= 8'h97; s_box[8][6] <= 8'h44; s_box[8][7] <= 8'h17;
			s_box[8][8] <= 8'hc4; s_box[8][9] <= 8'ha7; s_box[8][10] <= 8'h7e; s_box[8][11] <= 8'h3d;
			s_box[8][12] <= 8'h64; s_box[8][13] <= 8'h5d; s_box[8][14] <= 8'h19; s_box[8][15] <= 8'h73;

			s_box[9][0] <= 8'h60; s_box[9][1] <= 8'h81; s_box[9][2] <= 8'h4f; s_box[9][3] <= 8'hdc;
			s_box[9][4] <= 8'h22; s_box[9][5] <= 8'h2a; s_box[9][6] <= 8'h90; s_box[9][7] <= 8'h88;
			s_box[9][8] <= 8'h46; s_box[9][9] <= 8'hee; s_box[9][10] <= 8'hb8; s_box[9][11] <= 8'h14;
			s_box[9][12] <= 8'hde; s_box[9][13] <= 8'h5e; s_box[9][14] <= 8'h0b; s_box[9][15] <= 8'hdb;

			s_box[10][0] <= 8'he0; s_box[10][1] <= 8'h32; s_box[10][2] <= 8'h3a; s_box[10][3] <= 8'h0a;
			s_box[10][4] <= 8'h49; s_box[10][5] <= 8'h06; s_box[10][6] <= 8'h24; s_box[10][7] <= 8'h5c;
			s_box[10][8] <= 8'hc2; s_box[10][9] <= 8'hd3; s_box[10][10] <= 8'hac; s_box[10][11] <= 8'h62;
			s_box[10][12] <= 8'h91; s_box[10][13] <= 8'h95; s_box[10][14] <= 8'he4; s_box[10][15] <= 8'h79;

			s_box[11][0] <= 8'he7; s_box[11][1] <= 8'hc8; s_box[11][2] <= 8'h37; s_box[11][3] <= 8'h6d;
			s_box[11][4] <= 8'h8d; s_box[11][5] <= 8'hd5; s_box[11][6] <= 8'h4e; s_box[11][7] <= 8'ha9;
			s_box[11][8] <= 8'h6c; s_box[11][9] <= 8'h56; s_box[11][10] <= 8'hf4; s_box[11][11] <= 8'hea;
			s_box[11][12] <= 8'h65; s_box[11][13] <= 8'h7a; s_box[11][14] <= 8'hae; s_box[11][15] <= 8'h08;

			s_box[12][0] <= 8'hba; s_box[12][1] <= 8'h78; s_box[12][2] <= 8'h25; s_box[12][3] <= 8'h2e;
			s_box[12][4] <= 8'h1c; s_box[12][5] <= 8'ha6; s_box[12][6] <= 8'hb4; s_box[12][7] <= 8'hc6;
			s_box[12][8] <= 8'he8; s_box[12][9] <= 8'hdd; s_box[12][10] <= 8'h74; s_box[12][11] <= 8'h1f;
			s_box[12][12] <= 8'h4b; s_box[12][13] <= 8'hbd; s_box[12][14] <= 8'h8b; s_box[12][15] <= 8'h8a;

			s_box[13][0] <= 8'h70; s_box[13][1] <= 8'h3e; s_box[13][2] <= 8'hb5; s_box[13][3] <= 8'h66;
			s_box[13][4] <= 8'h48; s_box[13][5] <= 8'h03; s_box[13][6] <= 8'hf6; s_box[13][7] <= 8'h0e;
			s_box[13][8] <= 8'h61; s_box[13][9] <= 8'h35; s_box[13][10] <= 8'h57; s_box[13][11] <= 8'hb9;
			s_box[13][12] <= 8'h86; s_box[13][13] <= 8'hc1; s_box[13][14] <= 8'h1d; s_box[13][15] <= 8'h9e;

			s_box[14][0] <= 8'he1; s_box[14][1] <= 8'hf8; s_box[14][2] <= 8'h98; s_box[14][3] <= 8'h11;
			s_box[14][4] <= 8'h69; s_box[14][5] <= 8'hd9; s_box[14][6] <= 8'h8e; s_box[14][7] <= 8'h94;
			s_box[14][8] <= 8'h9b; s_box[14][9] <= 8'h1e; s_box[14][10] <= 8'h87; s_box[14][11] <= 8'he9;
			s_box[14][12] <= 8'hce; s_box[14][13] <= 8'h55; s_box[14][14] <= 8'h28; s_box[14][15] <= 8'hdf;

			s_box[15][0] <= 8'h8c; s_box[15][1] <= 8'ha1; s_box[15][2] <= 8'h89; s_box[15][3] <= 8'h0d;
			s_box[15][4] <= 8'hbf; s_box[15][5] <= 8'he6; s_box[15][6] <= 8'h42; s_box[15][7] <= 8'h68;
			s_box[15][8] <= 8'h41; s_box[15][9] <= 8'h99; s_box[15][10] <= 8'h2d; s_box[15][11] <= 8'h0f;
			s_box[15][12] <= 8'hb0; s_box[15][13] <= 8'h54; s_box[15][14] <= 8'hbb; s_box[15][15] <= 8'h16;

			rijandael[0][0] <= 8'h02; rijandael[0][1] <= 8'h03; rijandael[0][2] <= 8'h01; rijandael[0][3] <= 8'h01;
			rijandael[1][0] <= 8'h01; rijandael[1][1] <= 8'h02; rijandael[1][2] <= 8'h03; rijandael[1][3] <= 8'h01;
			rijandael[2][0] <= 8'h01; rijandael[2][1] <= 8'h01; rijandael[2][2] <= 8'h02; rijandael[2][3] <= 8'h03;
			rijandael[3][0] <= 8'h03; rijandael[3][1] <= 8'h01; rijandael[3][2] <= 8'h01; rijandael[3][3] <= 8'h02;

			rcon[0][0] <= 8'h01; rcon[1][0] <= 8'h00; rcon[2][0] <= 8'h00; rcon[3][0] <= 8'h00;
			rcon[0][1] <= 8'h02; rcon[1][1] <= 8'h00; rcon[2][1] <= 8'h00; rcon[3][1] <= 8'h00;
			rcon[0][2] <= 8'h04; rcon[1][2] <= 8'h00; rcon[2][2] <= 8'h00; rcon[3][2] <= 8'h00;
			rcon[0][3] <= 8'h08; rcon[1][3] <= 8'h00; rcon[2][3] <= 8'h00; rcon[3][3] <= 8'h00;
			rcon[0][4] <= 8'h10; rcon[1][4] <= 8'h00; rcon[2][4] <= 8'h00; rcon[3][4] <= 8'h00;
			rcon[0][5] <= 8'h20; rcon[1][5] <= 8'h00; rcon[2][5] <= 8'h00; rcon[3][5] <= 8'h00;
			rcon[0][6] <= 8'h40; rcon[1][6] <= 8'h00; rcon[2][6] <= 8'h00; rcon[3][6] <= 8'h00;
			rcon[0][7] <= 8'h80; rcon[1][7] <= 8'h00; rcon[2][7] <= 8'h00; rcon[3][7] <= 8'h00;
			rcon[0][8] <= 8'h1B; rcon[1][8] <= 8'h00; rcon[2][8] <= 8'h00; rcon[3][8] <= 8'h00;
			rcon[0][9] <= 8'h36; rcon[1][9] <= 8'h00; rcon[2][9] <= 8'h00; rcon[3][9] <= 8'h00;
		end
		else begin
			state_current<=state_next;
			counter_reg<=counter_next;
			for(i=0;i<4;i=i+1) 
				for(j=0;j<4;j=j+1)
					mem_reg[j][i]<=mem_next[j][i];
		end
	
	integer m,n,r;
	always@(*) begin
		r=0;
		for(m=0;m<4;m=m+1) begin
			mem_temp[m]=0;
			mem_temp_2[m]=0;
			for(n=0;n<4;n=n+1) begin
					mem_next[n][m]=mem_reg[n][m];
					key[n][m]=key[n][m];
			end			
		end	
		counter_next=counter_reg;			
		case(state_current) 
			IDLE: if(start)
					state_next=ROUND_INI;
				  else	
				  	state_next=IDLE;

			ROUND_INI: begin
						state_next=SUBBYTES;
						for(m=0;m<4;m=m+1) 
							for(n=0;n<4;n=n+1)
								mem_next[n][m]=plaintext[n][m]^key[n][m];
			end	

			SUBBYTES: begin
						state_next=SHIFTROW;
						for(m=0;m<4;m=m+1) 
							for(n=0;n<4;n=n+1)
								mem_next[n][m]=s_box[mem_reg[n][m][7:4]][mem_reg[n][m][3:0]];
					  end 

			SHIFTROW: begin
						mem_next[1][0]=mem_reg[1][1]; mem_next[1][1]=mem_reg[1][2]; mem_next[1][2]=mem_reg[1][3]; mem_next[1][3]=mem_reg[1][0];
						mem_next[2][0]=mem_reg[2][2]; mem_next[2][1]=mem_reg[2][3]; mem_next[2][2]=mem_reg[2][0]; mem_next[2][3]=mem_reg[2][1];
						mem_next[3][0]=mem_reg[3][3]; mem_next[3][1]=mem_reg[3][0]; mem_next[3][2]=mem_reg[3][1]; mem_next[3][3]=mem_reg[3][2];
						if(counter_reg<9)
							state_next=MIXCOL;
						else 
							state_next=ROUNDKEY;
						counter_next=counter_reg+1;	
					end	

			MIXCOL: begin
						for(m=0;m<4;m=m+1)
							for(r=0;r<4;r=r+1) begin
								for(n=0;n<4;n=n+1)
									if(rijandael[r][n]==8'h01)
										mem_temp[n]=mem_reg[n][m];
									else if (rijandael[r][n]==8'h02)
										if(mem_reg[n][m][7]==1)
											mem_temp[n]=(mem_reg[n][m]<<1) ^ 8'b00011011;
										else	
											mem_temp[n]=mem_reg[n][m]<<1;
									else begin	
										if(mem_reg[n][m][7]==1)
											mem_temp[n]=(mem_reg[n][m]<<1) ^ 8'b00011011;
										else	
											mem_temp[n]=mem_reg[n][m]<<1;
										mem_temp[n]=mem_temp[n]^mem_reg[n][m];
									end	
								mem_next[r][m]=mem_temp[0]^mem_temp[1]^mem_temp[2]^mem_temp[3];			
							end				
						state_next=ROUNDKEY;				
					end
				
				ROUNDKEY: begin
							for(n=0;n<4;n=n+1)
								mem_temp[n]=key[n][3];
							mem_temp_2[0]=mem_temp[1];
							mem_temp_2[1]=mem_temp[2];
							mem_temp_2[2]=mem_temp[3];
							mem_temp_2[3]=mem_temp[0];
							for(n=0;n<4;n=n+1) begin
								mem_temp_2[n]=s_box[mem_temp_2[n][7:4]][mem_temp_2[n][3:0]];
								key[n][0]=mem_temp_2[n]^key[n][0]^rcon[n][counter_reg-1];
							end	
							for(m=1;m<4;m=m+1) 
								for(r=0;r<4;r=r+1)
									key[r][m]=key[r][m-1]^key[r][m];
							for(m=0;m<4;m=m+1) 
								for(n=0;n<4;n=n+1)
								mem_next[n][m]=mem_reg[n][m]^key[n][m];		
							if(counter_reg==10) begin
								state_next=RESULT;
								counter_next=0;	
							end	
							else			
								state_next=SUBBYTES;
						  end

				default: begin
							state_next=IDLE;	
						end		  				  
			endcase	
		end	

		integer a,b,c;
		always@(*) begin
			c=0;
			if(state_current==RESULT)
				for(a=0;a<4;a=a+1) 
					for(b=0;b<4;b=b+1) begin
						out[127 - 8*c -: 8]=mem_reg[a][b];
						c=c+1;
					end	
			else
				for(a=0;a<4;a=a+1) 
					for(b=0;b<4;b=b+1) begin
						out[127 - 8*c -: 8]=0;
						c=c+1;
					end				
		end			



endmodule

