-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY DDS_data_drive_test IS
  END DDS_data_drive_test;

  ARCHITECTURE behavior OF DDS_data_drive_test IS 
    signal data_len : integer := 64;
  -- Component Declaration
          COMPONENT DDS_data_drive
          PORT(
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (data_len-1 downto 0);
           enable : in  STD_LOGIC;
           recieve : out  STD_LOGIC;
           data_out_1 : out  STD_LOGIC_VECTOR (data_len-1 downto 0);
           data_out_2 : out  STD_LOGIC_VECTOR (data_len-1 downto 0);
           dds1_data : in  STD_LOGIC_VECTOR (7 downto 0);
           dds2_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  req_dds_1	:	out	std_logic;
			  req_dds_2	:	out	std_logic;
			  enable_1	:	in	std_logic;
			  enable_2	:	in	std_logic
                  );
          END COMPONENT;

           signal clk : std_logic := '0';
           signal rst : std_logic := '0';
           signal data_in : std_logic_vector(data_len-1 downto 0) := "0000000000000000011101100110011001100110011001100110011001100110";
           signal enable : std_logic := '0';
           signal recieve : std_logic;
           signal data_out_1 : std_logic_vector(data_len-1 downto 0);
           signal data_out_2 : std_logic_vector(data_len-1 downto 0);
           signal dds1_data : std_logic_vector(7 downto 0) := (others => '0');
           signal dds2_data : std_logic_vector(7 downto 0) := (others => '0');
	        signal req_dds_1	: std_logic;
	        signal req_dds_2	: std_logic;
	        signal enable_1	: std_logic := '1';
	        signal enable_2	: std_logic := '1';
          
			 

  BEGIN

  -- Component Instantiation
          uut: DDS_data_drive PORT MAP(
           clk => clk,
           rst => rst,
           data_in => data_in,
           enable => enable,
           recieve => recieve,
           data_out_1 => data_out_1,
           data_out_2 => data_out_2,
           dds1_data => dds1_data,
           dds2_data => dds2_data,
			  req_dds_1 => req_dds_1,
			  req_dds_2 => req_dds_2,
			  enable_1 => enable_1,
			  enable_2 => enable_2
          );

    --ƒNƒƒbƒN(10MHz)
    process begin
       CLK <= '0';
       wait for 50 ns;
       CLK <= '1';
       wait for 50 ns;
    end process;
	 
    rst      <= '1' after 100 us, '0' after 200 us;
	 enable    <= '1' after 300 us, '0' after 305 us;
	 dds1_data <= "00000001" after 400 us, "00000000" after 500 us;
	 enable_1  <= '0' after 400 us, '1' after 700 us;

  END;
