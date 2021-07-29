module digital_lock #(

	parameter	width = 4 //define the width of the password, in this case, I difine the width of 4, but it could be changed.
	
)(
	input 				clock,
	input 				reset,
	input				[3:0] key,

	output reg		[6:0] HEX0,
	output reg		[6:0] HEX1,
	output reg		[6:0] HEX2,
	output reg		[6:0] HEX3,
	output reg		[6:0] HEX4,
	output reg		[6:0] HEX5,
	
	//Indicates the current state of the lock
	output reg 			LOCK_STATE,
	output reg 			UNLOCK_STATE,
	output reg 			ORIGIN_STATE,
	output reg 			SECOND_STATE,
	output reg 			THIRD_STATE

);

// state-machine registers
reg	[6:0] state;



//Indicates the previous state of the button
reg 	 		key0_last;
reg	 		key1_last;
reg	 		key2_last;
reg	 		key3_last;


//state name
localparam	UNLOCKED		=	7'b0000000;
localparam	LOCKED		=	7'b0000001;
localparam	ORIGIN		=	7'b0000010;
localparam	SECOND		=	7'b0000100;
localparam	THIRD			= 	7'b0001000;
localparam	LOCKING		=	7'b0010000;
localparam	UNLOCKING	=	7'b0100000;

//Variables used to store data
reg	[2*width-1:0]	password_origin; // store the origin password
reg	[2*width-1:0]	password_second; // store the enterd password after the first try
reg	[2*width-1:0]	password_unlock;// store the enterd password which use to unlock the digital lock
reg 	[27:0]			counter;                   

wire [1:0] x1 = 2'b00;	// x1 represents the value represented when key[0] is pressed 
wire [1:0] x2 = 2'b01;	// x2 represents the value represented when key[1] is pressed.
wire [1:0] x3 = 2'b10;	// x3 represents the value represented when key[2] is pressed.
wire [1:0] x4 = 2'b11;	// x4 represents the value represented when key[3] is pressed.



integer i,s,t;

integer i_e,s_e,t_e;//Indicate if has any error in entered password
wire timecount = 4'b0;
reg t_h;
assign timecount = t_h;			// count how many times keys were pressed
// set a counter to control some states overtime or not
always @ (posedge clock) begin
		if (!reset) begin 
			counter				<= 28'd0; // when reset signal was high, reset the counter's value to 0
		end
		else begin 
			if (counter < 28'd24_999_999)	// count 1 second
				counter			<= counter + 1'b1; // due to the clock was 50MHz, so it would count24999999 times, then we have 1 second
			else begin 
				counter 			<= 28'd0; // when counter reach the peak, set counter to 0, and repeat the whole steps again
				t_h		<= timecount + 4'b0001; // timecount plus one means the machine has working one more second
			end 
		end
end


//state machine transitions
always @ (posedge clock) begin 
		if (!reset) begin 
			// reset all variables 
			password_origin 	<= 0; 
			password_second	<= 0;
			password_unlock	<=	0;
			t_h			 		<= 4'b0;	
			state					<= 7'b0000000;
			i						<= 4'b0;
			s						<= 4'b0;
			t						<= 4'b0;

			s_e					<= 1'b0;
			t_e					<= 1'b0;
			
			LOCK_STATE	<= 1'b1; // set all displays off
			UNLOCK_STATE<= 1'b1;
			ORIGIN_STATE<= 1'b1;
			SECOND_STATE<= 1'b1;
			THIRD_STATE <= 1'b1;
		end
		else begin 
			//Indicates the previous state of the button
			key0_last			<= key[0];
			key1_last			<= key[1];
			key2_last			<= key[2];
			key3_last			<= key[3];
			
			case (state) 
			
				UNLOCKED 	: begin 
					LOCK_STATE	<= 1'b0;
					UNLOCK_STATE<= 1'b1;
					ORIGIN_STATE<= 1'b0;
					SECOND_STATE<= 1'b0;
					THIRD_STATE <= 1'b0;
					
					if (key0_last && ~key[0]) begin // when user want to unlock ,press key[0]
						HEX5		<= 7'b1111111;
						HEX4		<= 7'b1111111;
						HEX3		<= 7'b1111111;
						HEX2		<= 7'b1111111;
						HEX1		<= 7'b1111111;
						HEX0		<= 7'b1111111;
						s_e		<= 1'b0;
						t_h		<= 4'b0; // set timecount to 0 as a start time of ORIGIN state 
						state		<= ORIGIN; // jump to ORIGIN state
					end
					else if (s_e == 1'b1) begin 
						HEX5		<= 7'b0000110;
						HEX4		<= 7'b0101111;
						HEX3		<= 7'b0101111;
						HEX2		<= 7'b0100011;
						HEX1		<= 7'b0101111;
						HEX0		<= 7'b1111111;
					end
					else begin 
						
						HEX5		<= 7'b1000001;
						HEX4		<= 7'b0101011;
						HEX3		<= 7'b1000111;
						HEX2		<= 7'b0100011;
						HEX1		<= 7'b0100111;
						HEX0		<= 7'b0000101;
						state		<= UNLOCKED; // keep in UNLOCKED state 
					end
				end
				
				ORIGIN		: begin	// the state which the origin password was enterd
					LOCK_STATE	<= 1'b0;
					UNLOCK_STATE<= 1'b0;
					ORIGIN_STATE<= 1'b1;
					SECOND_STATE<= 1'b0;
					THIRD_STATE <= 1'b0;							//If do nothing, keep it unlocked
					
					
					if 		  (i == width && key1_last && ~key[1]) begin // when the whole password was enterd, stop put x1-x4 into the password_origin
						HEX5		<= 7'b1111111;
						HEX4		<= 7'b1111111;
						HEX3		<= 7'b1111111;
						HEX2		<= 7'b1111111;
						HEX1		<= 7'b1111111;
						HEX0		<= 7'b1111111;
						t_h		<= 4'b0;	 // set timecount to 0 as a start time of SECOND state
						i			 = 0;	 // set i to 0 to prevent a latch
						state		<= SECOND;	// jump to SECOND state	
					end
					else if 	  (t_h > 4'b0101 ) begin // user have 5 seconds to enter the password, the time limit could be changed
						t_h		<= 4'b0;
						state		<= UNLOCKED; // jump to UNLOCKED state
					end
					else begin 
						
						if 	  (key0_last && ~key[0]) begin  // if key[0] was pressed, put x1 into the [2 * i +:2] of password_origin, because the password have the sequence, the key first pressed should
							password_origin [2 * i +:2] <= x1; // put into the right side of the password_origin, second was next the first two-bit value, from right to left
							i	= i + 1; // i is the order in which the keys are pressed. after a key was pressed, plus one.
						end
						else if (key1_last && ~key[1]) begin 
							password_origin [2 * i +:2] <= x2; // same with the first key.
							i	= i + 1;
						end
						else if (key2_last && ~key[2]) begin 
							password_origin [2 * i +:2] <= x3;
							i	= i + 1;
						end
						else if (key3_last && ~key[3]) begin 
							password_origin [2 * i +:2] <= x4;
							i	= i + 1;
						end
						else begin
							
							if 	  (i	== 1) begin 
								if 	  (password_origin [2 * (i-1) +:2] == x1) begin 
									HEX5		<= 7'b1111001;
								end
								else if (password_origin [2 * (i-1) +:2] == x2) begin 
									HEX5		<= 7'b0100100;
								end
								else if (password_origin [2 * (i-1) +:2] == x3) begin 
									HEX5		<= 7'b0110000;
								end
								else if (password_origin [2 * (i-1) +:2] == x4) begin 
									HEX5		<= 7'b0011001;
								end
								else begin 
									HEX5		<= 7'b1111111;
								end
							end
							else if (i	== 2) begin 
								if 	  (password_origin [2 * (i-1) +:2] == x1) begin 
									HEX4		<= 7'b1111001;
								end
								else if (password_origin [2 * (i-1) +:2] == x2) begin 
									HEX4		<= 7'b0100100;
								end
								else if (password_origin [2 * (i-1) +:2] == x3) begin 
									HEX4		<= 7'b0110000;
								end
								else if (password_origin [2 * (i-1) +:2] == x4) begin 
									HEX4		<= 7'b0011001;
								end
								else begin 
									HEX4		<= 7'b1111111;
								end
							end
							else if (i	== 3) begin 
								if 	  (password_origin [2 * (i-1) +:2] == x1) begin 
									HEX3		<= 7'b1111001;
								end
								else if (password_origin [2 * (i-1) +:2] == x2) begin 
									HEX3		<= 7'b0100100;
								end
								else if (password_origin [2 * (i-1) +:2] == x3) begin 
									HEX3		<= 7'b0110000;
								end
								else if (password_origin [2 * (i-1) +:2] == x4) begin 
									HEX3		<= 7'b0011001;
								end
								else begin 
									HEX3		<= 7'b1111111;
								end
							end
							else if (i	== 4) begin 

								if 	  (password_origin [2 * (i-1) +:2] == x1) begin 
									HEX2		<= 7'b1111001;
								end
								else if (password_origin [2 * (i-1) +:2] == x2) begin 
									HEX2		<= 7'b0100100;
								end
								else if (password_origin [2 * (i-1) +:2] == x3) begin 
									HEX2		<= 7'b0110000;
								end
								else if (password_origin [2 * (i-1) +:2] == x4) begin 
									HEX2		<= 7'b0011001;
								end
								else begin 
									HEX2		<= 7'b1111111;
								end
							end
							else if (i	== 5) begin 

								if 	  (password_origin [2 * (i-1) +:2] == x1) begin 
									HEX1		<= 7'b1111001;
								end
								else if (password_origin [2 * (i-1) +:2] == x2) begin 
									HEX1		<= 7'b0100100;
								end
								else if (password_origin [2 * (i-1) +:2] == x3) begin 
									HEX1		<= 7'b0110000;
								end
								else if (password_origin [2 * (i-1) +:2] == x4) begin 
									HEX1		<= 7'b0011001;
								end
								else begin 
									HEX1		<= 7'b1111111;
								end
							end
							else if (i	== 6) begin 

								if 	  (password_origin [2 * (i-1) +:2] == x1) begin 
									HEX0		<= 7'b1111001;
								end
								else if (password_origin [2 * (i-1) +:2] == x2) begin 
									HEX0		<= 7'b0100100;
								end
								else if (password_origin [2 * (i-1) +:2] == x3) begin 
									HEX0		<= 7'b0110000;
								end
								else if (password_origin [2 * (i-1) +:2] == x4) begin 
									HEX0		<= 7'b0011001;
								end
								else begin 
									HEX0		<= 7'b1111111;
								end
							end
							else begin 
								HEX5		<= 7'b1111111;
								HEX4		<= 7'b1111111;
								HEX3		<= 7'b1111111;
								HEX2		<= 7'b1111111;
								HEX1		<= 7'b1111111;
								HEX0		<= 7'b1111111;
							end

						end
					end
				end
				
				SECOND		: begin  //the state which the second password was enterd, to compare with the origin password
					LOCK_STATE	<= 1'b0;
					UNLOCK_STATE<= 1'b0;
					ORIGIN_STATE<= 1'b0;
					SECOND_STATE<= 1'b1;
					THIRD_STATE <= 1'b0;						 //If do nothing, keep it unlocked
					
					
					if 		  (s == width && key1_last && ~key[1]) begin // when the whole password was enterd, stop put x1-x4 into the password_second
						HEX5		<= 7'b1111111;
						HEX4		<= 7'b1111111;
						HEX3		<= 7'b1111111;
						HEX2		<= 7'b1111111;
						HEX1		<= 7'b1111111;
						HEX0		<= 7'b1111111;
						t_h		<= 4'b0;
						s			 = 0; // set s to 0 to prevent a latch
						state 	<= LOCKING; // jump to LOCKING state
					end
					else if (t_h > 4'b0101 ) begin // user have 5 seconds to enter the password
						t_h		<= 4'b0;
						state		<= UNLOCKED; // jump to UNLOCK state
					end
					else begin 
						if 	  (key0_last && ~key[0]) begin  // same with ORIGIN state.
							password_second [2 * s +:2] <= x1;
							s	= s + 1;
						end
						else if (key1_last && ~key[1]) begin 
							password_second [2 * s +:2] <= x2;
							s	= s + 1;
						end
						else if (key2_last && ~key[2]) begin 
							password_second [2 * s +:2] <= x3;
							s	= s + 1;
						end
						else if (key3_last && ~key[3]) begin 
							password_second [2 * s +:2] <= x4;
							s	= s + 1;
						end
						else begin
							
							if 	  (s	== 1) begin 
								if 	  (password_second [2 * (s-1) +:2] == x1) begin 
									HEX5		<= 7'b1111001;
								end
								else if (password_second [2 * (s-1) +:2] == x2) begin 
									HEX5		<= 7'b0100100;
								end
								else if (password_second [2 * (s-1) +:2] == x3) begin 
									HEX5		<= 7'b0110000;
								end
								else if (password_second [2 * (s-1) +:2] == x4) begin 
									HEX5		<= 7'b0011001;
								end
								else begin 
									HEX5		<= 7'b1111111;
								end
							end
							else if (s	== 2) begin 
								if 	  (password_second [2 * (s-1) +:2] == x1) begin 
									HEX4		<= 7'b1111001;
								end
								else if (password_second [2 * (s-1) +:2] == x2) begin 
									HEX4		<= 7'b0100100;
								end
								else if (password_second [2 * (s-1) +:2] == x3) begin 
									HEX4		<= 7'b0110000;
								end
								else if (password_second [2 * (s-1) +:2] == x4) begin 
									HEX4		<= 7'b0011001;
								end
								else begin 
									HEX4		<= 7'b1111111;
								end
							end
							else if (s	== 3) begin 
								if 	  (password_second [2 * (s-1) +:2] == x1) begin 
									HEX3		<= 7'b1111001;
								end
								else if (password_second [2 * (s-1) +:2] == x2) begin 
									HEX3		<= 7'b0100100;
								end
								else if (password_second [2 * (s-1) +:2] == x3) begin 
									HEX3		<= 7'b0110000;
								end
								else if (password_second [2 * (s-1) +:2] == x4) begin 
									HEX3		<= 7'b0011001;
								end
								else begin 
									HEX3		<= 7'b1111111;
								end
							end
							else if (s	== 4) begin 

								if 	  (password_second [2 * (s-1) +:2] == x1) begin 
									HEX2		<= 7'b1111001;
								end
								else if (password_second [2 * (s-1) +:2] == x2) begin 
									HEX2		<= 7'b0100100;
								end
								else if (password_second [2 * (s-1) +:2] == x3) begin 
									HEX2		<= 7'b0110000;
								end
								else if (password_second [2 * (s-1) +:2] == x4) begin 
									HEX2		<= 7'b0011001;
								end
								else begin 
									HEX2		<= 7'b1111111;
								end
							end
							else if (s	== 5) begin 

								if 	  (password_second [2 * (s-1) +:2] == x1) begin 
									HEX1		<= 7'b1111001;
								end
								else if (password_second [2 * (s-1) +:2] == x2) begin 
									HEX1		<= 7'b0100100;
								end
								else if (password_second [2 * (s-1) +:2] == x3) begin 
									HEX1		<= 7'b0110000;
								end
								else if (password_second [2 * (s-1) +:2] == x4) begin 
									HEX1		<= 7'b0011001;
								end
								else begin 
									HEX1		<= 7'b1111111;
								end
							end
							else if (s	== 6) begin 

								if 	  (password_second [2 * (s-1) +:2] == x1) begin 
									HEX0		<= 7'b1111001;
								end
								else if (password_second [2 * (s-1) +:2] == x2) begin 
									HEX0		<= 7'b0100100;
								end
								else if (password_second [2 * (s-1) +:2] == x3) begin 
									HEX0		<= 7'b0110000;
								end
								else if (password_second [2 * (s-1) +:2] == x4) begin 
									HEX0		<= 7'b0011001;
								end
								else begin 
									HEX0		<= 7'b1111111;
								end
							end
							else begin 
								HEX5		<= 7'b1111111;
								HEX4		<= 7'b1111111;
								HEX3		<= 7'b1111111;
								HEX2		<= 7'b1111111;
								HEX1		<= 7'b1111111;
								HEX0		<= 7'b1111111;
							end
						end
					end
					
				end 
				
				LOCKING		: begin // Used to compare the password entered the first time with the password entered the second time
					
					
					if (password_origin	== password_second) begin 
						
						state				<= LOCKED;// jump to LOCKED state
					end
					else begin 
						s_e				<= 1'b1;
						state				<= UNLOCKED; // jump to UNLOCKED state
					end
				end
			
				LOCKED		: begin 
					LOCK_STATE	<= 1'b1;
					UNLOCK_STATE<= 1'b0;
					ORIGIN_STATE<= 1'b0;
					SECOND_STATE<= 1'b0;
					THIRD_STATE <= 1'b0;//If do nothing, keep it locked
					
					if (key3_last && ~key[3]) begin  // when user want to unlock, press key[3]
						HEX5		<= 7'b1111111;
						HEX4		<= 7'b1111111;
						HEX3		<= 7'b1111111;
						HEX2		<= 7'b1111111;
						HEX1		<= 7'b1111111;
						HEX0		<= 7'b1111111;
						t_h		<= 4'b0;// set timecount to 0 as a start time of THIRD state
						state		<= THIRD;// jump to THIRD state
					end
					else if (t_e == 1'b1) begin 
						HEX5		<= 7'b0000110;
						HEX4		<= 7'b0101111;
						HEX3		<= 7'b0101111;
						HEX2		<= 7'b0100011;
						HEX1		<= 7'b0101111;
						HEX0		<= 7'b1111111;
					end
					else begin 
						
						HEX5		<= 7'b1000111;
						HEX4		<= 7'b0100011;
						HEX3		<= 7'b0100111;
						HEX2		<= 7'b0000101;
						HEX1		<= 7'b1111111;
						HEX0		<= 7'b1111111;
						state		<= LOCKED;// if no kep pressed, keep the state unchanged
					end
				end
				
				THIRD			: begin //the state which the unlock password was enterd, to compare with the origin password
					LOCK_STATE	<= 1'b0;
					UNLOCK_STATE<= 1'b0;
					ORIGIN_STATE<= 1'b0;
					SECOND_STATE<= 1'b0;
					THIRD_STATE <= 1'b1;						//If do nothing, keep it locked
					
					if (t == width && key1_last && ~key[1]) begin // when the whole password was enterd, stop put x1-x4 into the password_unlock
						HEX5		<= 7'b1111111;
						HEX4		<= 7'b1111111;
						HEX3		<= 7'b1111111;
						HEX2		<= 7'b1111111;
						HEX1		<= 7'b1111111;
						HEX0		<= 7'b1111111;
						t_h		<= 4'b0;
						t			<= 4'b0;// set t to 0 to prevent a latch
						state 	<= UNLOCKING;//jump to LOCKING state
					end
					else if 	  (t_h > 4'b0101 ) begin // user have 5 seconds to enter the password
						state		<= LOCKED;//jump to LOCKED state
					end
					else begin
						if 	  (key0_last && ~key[0]) begin // same with ORIGIN part
							password_unlock [2 * t +:2] <= x1;
							t = t + 1;
						end
						else if (key1_last && ~key[1]) begin 
							password_unlock [2 * t +:2] <= x2;
							t = t + 1;
						end
						else if (key2_last && ~key[2]) begin 
							password_unlock [2 * t +:2] <= x3;
							t = t + 1;
						end
						else if (key3_last && ~key[3]) begin 
							password_unlock [2 * t +:2] <= x4;
							t = t + 1;
						end
						else begin
							
							if 	  (t	== 1) begin 
								if 	  (password_unlock [2 * (t-1) +:2] == x1) begin 
									HEX5		<= 7'b1111001;
								end
								else if (password_unlock [2 * (t-1) +:2] == x2) begin 
									HEX5		<= 7'b0100100;
								end
								else if (password_unlock [2 * (t-1) +:2] == x3) begin 
									HEX5		<= 7'b0110000;
								end
								else if (password_unlock [2 * (t-1) +:2] == x4) begin 
									HEX5		<= 7'b0011001;
								end
								else begin 
									HEX5		<= 7'b1111111;
								end
							end
							else if (t	== 2) begin 
								if 	  (password_unlock [2 * (t-1) +:2] == x1) begin 
									HEX4		<= 7'b1111001;
								end
								else if (password_unlock [2 * (t-1) +:2] == x2) begin 
									HEX4		<= 7'b0100100;
								end
								else if (password_unlock [2 * (t-1) +:2] == x3) begin 
									HEX4		<= 7'b0110000;
								end
								else if (password_unlock [2 * (t-1) +:2] == x4) begin 
									HEX4		<= 7'b0011001;
								end
								else begin 
									HEX4		<= 7'b1111111;
								end
							end
							else if (t	== 3) begin 
								if 	  (password_unlock [2 * (t-1) +:2] == x1) begin 
									HEX3		<= 7'b1111001;
								end
								else if (password_unlock [2 * (t-1) +:2] == x2) begin 
									HEX3		<= 7'b0100100;
								end
								else if (password_unlock [2 * (t-1) +:2] == x3) begin 
									HEX3		<= 7'b0110000;
								end
								else if (password_unlock [2 * (t-1) +:2] == x4) begin 
									HEX3		<= 7'b0011001;
								end
								else begin 
									HEX3		<= 7'b1111111;
								end
							end
							else if (t	== 4) begin 

								if 	  (password_unlock [2 * (t-1) +:2] == x1) begin 
									HEX2		<= 7'b1111001;
								end
								else if (password_unlock [2 * (t-1) +:2] == x2) begin 
									HEX2		<= 7'b0100100;
								end
								else if (password_unlock [2 * (t-1) +:2] == x3) begin 
									HEX2		<= 7'b0110000;
								end
								else if (password_unlock [2 * (t-1) +:2] == x4) begin 
									HEX2		<= 7'b0011001;
								end
								else begin 
									HEX2		<= 7'b1111111;
								end
							end
							else if (t	== 5) begin 

								if 	  (password_unlock [2 * (t-1) +:2] == x1) begin 
									HEX1		<= 7'b1111001;
								end
								else if (password_unlock [2 * (t-1) +:2] == x2) begin 
									HEX1		<= 7'b0100100;
								end
								else if (password_unlock [2 * (t-1) +:2] == x3) begin 
									HEX1		<= 7'b0110000;
								end
								else if (password_unlock [2 * (t-1) +:2] == x4) begin 
									HEX1		<= 7'b0011001;
								end
								else begin 
									HEX1		<= 7'b1111111;
								end
							end
							else if (t	== 6) begin 

								if 	  (password_unlock [2 * (t-1) +:2] == x1) begin 
									HEX0		<= 7'b1111001;
								end
								else if (password_unlock [2 * (t-1) +:2] == x2) begin 
									HEX0		<= 7'b0100100;
								end
								else if (password_unlock [2 * (t-1) +:2] == x3) begin 
									HEX0		<= 7'b0110000;
								end
								else if (password_unlock [2 * (t-1) +:2] == x4) begin 
									HEX0		<= 7'b0011001;
								end
								else begin 
									HEX0		<= 7'b1111111;
								end
							end
							else begin 
								HEX5		<= 7'b1111111;
								HEX4		<= 7'b1111111;
								HEX3		<= 7'b1111111;
								HEX2		<= 7'b1111111;
								HEX1		<= 7'b1111111;
								HEX0		<= 7'b1111111;
							end
						end
					end
				end
				
				UNLOCKING	: begin // Used to compare the password entered the third time(unlock use) with the password entered the first time
					
					
					if (password_unlock	==	password_origin) begin 

						state 			<= UNLOCKED;// jump to UNLOCKED state
					end
					else begin 
						t_e				<= 1'b1;
						state				<= LOCKED;// jump to LOCKED state
					end
				end 
				
				default state			<= UNLOCKED;// the defalut state
			
			endcase
		end
end
endmodule