`timescale 1 ns/ 1 ns
module digital_lock_tb_error_in_LOCKING ();
// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg clock;
reg [3:0] key;
reg reset;
// wires                                               
wire [6:0]  HEX0;
wire [6:0]  HEX1;
wire [6:0]  HEX2;
wire [6:0]  HEX3;
wire [6:0]  HEX4;
wire [6:0]  HEX5;
wire LOCK_STATE;
wire ORIGIN_STATE;
wire SECOND_STATE;
wire THIRD_STATE;
wire UNLOCK_STATE;

// assign statements (if any)                          
digital_lock digital_lock_inst (
// port map - connection between master ports and signals/registers   
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),
	.LOCK_STATE(LOCK_STATE),
	.ORIGIN_STATE(ORIGIN_STATE),
	.SECOND_STATE(SECOND_STATE),
	.THIRD_STATE(THIRD_STATE),
	.UNLOCK_STATE(UNLOCK_STATE),
	.clock(clock),
	.key(key),
	.reset(reset)
);

wire[6:0] state = digital_lock_inst.state;

initial                                                
begin                                                  
// code that executes only once                        
// insert code here --> begin                          
    clock = 1'b1;
	 reset <= 1'b0;
	 key[3:0]<=4'b1111;//In the initial state, none of the four buttons are pressed, and the system is in an unlocked state. 
	 #20               //When key[0] is pressed, the system will change to the ORIGIN state
	 reset <= 1'b1;
	 #200
	 //UNLOCKED STATE
	 key[3:0]<=4'b1110;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 //ORIGIN STATE
	 key[3:0]<=4'b1110;//When the system enters the ORIGIN state, enter the initial password, the default is 1234
	 #2000 				  // After that, press key[1]  to confirm this action and let the system enters the SECOND state
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b1101;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b1011;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b0111;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b1101;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 //SECOND STATE
	 key[3:0]<=4'b0111;//When the system enters the SECOND state, enter the second password, the default is 1234,here we entered 4321 which is not match to origin password
	 #2000 				  // After that, press key[1]  to confirm this action and let the system enters the LOCKING state.
	 key[3:0]<=4'b1111; // If two passwords are matched, the system jump to LOCKED state, if not, back to the UNLOCKED state
	 #1000
	 key[3:0]<=4'b1011;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b1101;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b1110;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 key[3:0]<=4'b1101;
	 #2000
	 key[3:0]<=4'b1111;
	 #1000
	 
	 
	 
$display("Running testbench");                       
end 

initial 
begin
	$timeformat (-9,0,"ns",6);
	$monitor ("@time %t:key[0] = %b, key[1] = %b, key[2] = %b, key[3] = %b, LOCK_STATE = %b, ORIGIN_STATE = %b,  SECOND_STATE = %b, THIRD_STATE = %b, UNLOCK_STATE = %b",
					  $time,key[0],key[1],key[2],key[3],LOCK_STATE,ORIGIN_STATE,SECOND_STATE,THIRD_STATE,UNLOCK_STATE);

end 
always #10 clock = ~clock;
                                                  
                            
endmodule
