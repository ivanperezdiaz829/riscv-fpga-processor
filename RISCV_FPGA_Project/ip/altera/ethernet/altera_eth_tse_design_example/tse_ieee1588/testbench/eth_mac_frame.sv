// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`ifndef ETH_MAC_FRAME__SV
`define ETH_MAC_FRAME__SV

`include "default_test_params_pkg.sv"


	//Get test parameter from the package
	import default_test_params_pkt::*; 
 
	
// Class file to handle creation of Ethernet frame content
class eth_mac_frame;

    bit[7:0] frame_content[];
    
    // Constant for CRC calculation of the frame
    bit [31:0] crc_table[256] =
    '{
        32'h00000000, 32'h77073096, 32'hEE0E612C, 32'h990951BA,
        32'h076DC419, 32'h706AF48F, 32'hE963A535, 32'h9E6495A3,
        32'h0EDB8832, 32'h79DCB8A4, 32'hE0D5E91E, 32'h97D2D988,
        32'h09B64C2B, 32'h7EB17CBD, 32'hE7B82D07, 32'h90BF1D91,
        32'h1DB71064, 32'h6AB020F2, 32'hF3B97148, 32'h84BE41DE,
        32'h1ADAD47D, 32'h6DDDE4EB, 32'hF4D4B551, 32'h83D385C7,
        32'h136C9856, 32'h646BA8C0, 32'hFD62F97A, 32'h8A65C9EC,
        32'h14015C4F, 32'h63066CD9, 32'hFA0F3D63, 32'h8D080DF5,
        32'h3B6E20C8, 32'h4C69105E, 32'hD56041E4, 32'hA2677172,
        32'h3C03E4D1, 32'h4B04D447, 32'hD20D85FD, 32'hA50AB56B,
        32'h35B5A8FA, 32'h42B2986C, 32'hDBBBC9D6, 32'hACBCF940,
        32'h32D86CE3, 32'h45DF5C75, 32'hDCD60DCF, 32'hABD13D59,
        32'h26D930AC, 32'h51DE003A, 32'hC8D75180, 32'hBFD06116,
        32'h21B4F4B5, 32'h56B3C423, 32'hCFBA9599, 32'hB8BDA50F,
        32'h2802B89E, 32'h5F058808, 32'hC60CD9B2, 32'hB10BE924,
        32'h2F6F7C87, 32'h58684C11, 32'hC1611DAB, 32'hB6662D3D,
        32'h76DC4190, 32'h01DB7106, 32'h98D220BC, 32'hEFD5102A,
        32'h71B18589, 32'h06B6B51F, 32'h9FBFE4A5, 32'hE8B8D433,
        32'h7807C9A2, 32'h0F00F934, 32'h9609A88E, 32'hE10E9818,
        32'h7F6A0DBB, 32'h086D3D2D, 32'h91646C97, 32'hE6635C01,
        32'h6B6B51F4, 32'h1C6C6162, 32'h856530D8, 32'hF262004E,
        32'h6C0695ED, 32'h1B01A57B, 32'h8208F4C1, 32'hF50FC457,
        32'h65B0D9C6, 32'h12B7E950, 32'h8BBEB8EA, 32'hFCB9887C,
        32'h62DD1DDF, 32'h15DA2D49, 32'h8CD37CF3, 32'hFBD44C65,
        32'h4DB26158, 32'h3AB551CE, 32'hA3BC0074, 32'hD4BB30E2,
        32'h4ADFA541, 32'h3DD895D7, 32'hA4D1C46D, 32'hD3D6F4FB,
        32'h4369E96A, 32'h346ED9FC, 32'hAD678846, 32'hDA60B8D0,
        32'h44042D73, 32'h33031DE5, 32'hAA0A4C5F, 32'hDD0D7CC9,
        32'h5005713C, 32'h270241AA, 32'hBE0B1010, 32'hC90C2086,
        32'h5768B525, 32'h206F85B3, 32'hB966D409, 32'hCE61E49F,
        32'h5EDEF90E, 32'h29D9C998, 32'hB0D09822, 32'hC7D7A8B4,
        32'h59B33D17, 32'h2EB40D81, 32'hB7BD5C3B, 32'hC0BA6CAD,
        32'hEDB88320, 32'h9ABFB3B6, 32'h03B6E20C, 32'h74B1D29A,
        32'hEAD54739, 32'h9DD277AF, 32'h04DB2615, 32'h73DC1683,
        32'hE3630B12, 32'h94643B84, 32'h0D6D6A3E, 32'h7A6A5AA8,
        32'hE40ECF0B, 32'h9309FF9D, 32'h0A00AE27, 32'h7D079EB1,
        32'hF00F9344, 32'h8708A3D2, 32'h1E01F268, 32'h6906C2FE,
        32'hF762575D, 32'h806567CB, 32'h196C3671, 32'h6E6B06E7,
        32'hFED41B76, 32'h89D32BE0, 32'h10DA7A5A, 32'h67DD4ACC,
        32'hF9B9DF6F, 32'h8EBEEFF9, 32'h17B7BE43, 32'h60B08ED5,
        32'hD6D6A3E8, 32'hA1D1937E, 32'h38D8C2C4, 32'h4FDFF252,
        32'hD1BB67F1, 32'hA6BC5767, 32'h3FB506DD, 32'h48B2364B,
        32'hD80D2BDA, 32'hAF0A1B4C, 32'h36034AF6, 32'h41047A60,
        32'hDF60EFC3, 32'hA867DF55, 32'h316E8EEF, 32'h4669BE79,
        32'hCB61B38C, 32'hBC66831A, 32'h256FD2A0, 32'h5268E236,
        32'hCC0C7795, 32'hBB0B4703, 32'h220216B9, 32'h5505262F,
        32'hC5BA3BBE, 32'hB2BD0B28, 32'h2BB45A92, 32'h5CB36A04,
        32'hC2D7FFA7, 32'hB5D0CF31, 32'h2CD99E8B, 32'h5BDEAE1D,
        32'h9B64C2B0, 32'hEC63F226, 32'h756AA39C, 32'h026D930A,
        32'h9C0906A9, 32'hEB0E363F, 32'h72076785, 32'h05005713,
        32'h95BF4A82, 32'hE2B87A14, 32'h7BB12BAE, 32'h0CB61B38,
        32'h92D28E9B, 32'hE5D5BE0D, 32'h7CDCEFB7, 32'h0BDBDF21,
        32'h86D3D2D4, 32'hF1D4E242, 32'h68DDB3F8, 32'h1FDA836E,
        32'h81BE16CD, 32'hF6B9265B, 32'h6FB077E1, 32'h18B74777,
        32'h88085AE6, 32'hFF0F6A70, 32'h66063BCA, 32'h11010B5C,
        32'h8F659EFF, 32'hF862AE69, 32'h616BFFD3, 32'h166CCF45,
        32'hA00AE278, 32'hD70DD2EE, 32'h4E048354, 32'h3903B3C2,
        32'hA7672661, 32'hD06016F7, 32'h4969474D, 32'h3E6E77DB,
        32'hAED16A4A, 32'hD9D65ADC, 32'h40DF0B66, 32'h37D83BF0,
        32'hA9BCAE53, 32'hDEBB9EC5, 32'h47B2CF7F, 32'h30B5FFE9,
        32'hBDBDF21C, 32'hCABAC28A, 32'h53B39330, 32'h24B4A3A6,
        32'hBAD03605, 32'hCDD70693, 32'h54DE5729, 32'h23D967BF,
        32'hB3667A2E, 32'hC4614AB8, 32'h5D681B02, 32'h2A6F2B94,
        32'hB40BBE37, 32'hC30C8EA1, 32'h5A05DF1B, 32'h2D02EF8D
    };

  // Copy Function
    virtual function eth_mac_frame copy(eth_mac_frame to = null);
        eth_mac_frame cpy;
        
        if(to == null) begin
            cpy = new();
        end
        else begin
            $cast(cpy, to);
        end
        
        cpy.frame_content = new[this.frame_content.size()](this.frame_content);
        
        copy = cpy;
    endfunction

    
    // Return calculated CRC of the input frame_data[] dynamic array
    virtual function bit [31:0] calculate_crc(bit [7:0] frame_data[]);
        int unsigned i;
        int unsigned frame_data_size_prev;
        
        bit [31:0] crc_int;
        
        frame_data_size_prev = frame_data.size();
        
        // init CRC register with all one
        crc_int = 32'hffffffff;
        
        for(i = 0; i < frame_data_size_prev; i++ ) begin
            crc_int = crc_table[(crc_int & 8'hff) ^ frame_data[i]] ^ ((crc_int >> 8) & 32'h00ffffff);
        end
        
        crc_int = ~crc_int;
        
        return crc_int;
    endfunction
    
    
    
    // Append Destination Address to the reference frame_data[] dynamic array
    virtual function void insert_dest_addr(ref bit [7:0] frame_data[], input bit [47:0] dest_addr);
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 6](frame_data);
        
        frame_data[frame_data_size_prev + 5] = dest_addr[7:0];
        frame_data[frame_data_size_prev + 4] = dest_addr[15:8];
        frame_data[frame_data_size_prev + 3] = dest_addr[23:16];
        frame_data[frame_data_size_prev + 2] = dest_addr[31:24];
        frame_data[frame_data_size_prev + 1] = dest_addr[39:32];
        frame_data[frame_data_size_prev + 0] = dest_addr[47:40];
    endfunction
    
    
    
    // Append Source Address to the reference frame_data[] dynamic array
    virtual function void insert_src_addr(ref bit [7:0] frame_data[], input bit [47:0] src_addr);
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 6](frame_data);
        
        frame_data[frame_data_size_prev + 5] = src_addr[7:0];
        frame_data[frame_data_size_prev + 4] = src_addr[15:8];
        frame_data[frame_data_size_prev + 3] = src_addr[23:16];
        frame_data[frame_data_size_prev + 2] = src_addr[31:24];
        frame_data[frame_data_size_prev + 1] = src_addr[39:32];
        frame_data[frame_data_size_prev + 0] = src_addr[47:40];
    endfunction
    
    
    
    // Append VLAN Tag and VLAN Info to the reference frame_data[] dynamic array
    virtual function void insert_vlan_tag(ref bit [7:0] frame_data[], input bit [15:0] vlan_info);
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 4](frame_data);
        
        frame_data[frame_data_size_prev + 0] = 8'h81;
        frame_data[frame_data_size_prev + 1] = 8'h00;
        frame_data[frame_data_size_prev + 2] = vlan_info[15:8];
        frame_data[frame_data_size_prev + 3] = vlan_info[7:0];
    endfunction
    
    
    
    // Append Length/Type Field to the reference frame_data[] dynamic array
    virtual function void insert_length_type(ref bit [7:0] frame_data[], input bit [15:0] length_type);
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 2](frame_data);
        
        frame_data[frame_data_size_prev + 0] = length_type[15:8];
        frame_data[frame_data_size_prev + 1] = length_type[7:0];
    endfunction
    
    
    
    // Append Control Frame Opcode to the reference frame_data[] dynamic array
    virtual function void insert_control_opcode(ref bit [7:0] frame_data[], input bit [15:0] opcode);
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 2](frame_data);
        
        frame_data[frame_data_size_prev + 0] = opcode[15:8];
        frame_data[frame_data_size_prev + 1] = opcode[7:0];
    endfunction
    
    
    
    // Append IPv4 header to the reference frame_data[] dynamic array
    virtual function void insert_ipv4_header(ref bit [7:0] frame_data[], input bit [7:0] protocol);
        int unsigned i;
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 20](frame_data);
        
        for(i = 0; i < 20; i++) begin
            frame_data[frame_data_size_prev + i] = 8'hAA;
        end
        frame_data[frame_data_size_prev + 9] = protocol[7:0];
    endfunction
    
    
    
    // Append IPv6 header to the reference frame_data[] dynamic array
    virtual function void insert_ipv6_header(ref bit [7:0] frame_data[], input bit [7:0] protocol);
        int unsigned i;
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 40](frame_data);
        
        for(i = 0; i < 40; i++) begin
            frame_data[frame_data_size_prev + i] = 8'hBB;
        end
        frame_data[frame_data_size_prev + 6] = protocol[7:0];
    endfunction
    
    
    
    // Append UDP header to the reference frame_data[] dynamic array
    virtual function void insert_udp_header(ref bit [7:0] frame_data[], input bit [15:0] dest_port_num);
        int unsigned i;
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 8](frame_data);
        
        for(i = 0; i < 8; i++) begin
            frame_data[frame_data_size_prev + i] = 8'hCC;
        end
        frame_data[frame_data_size_prev + 3] = dest_port_num[7:0];
        frame_data[frame_data_size_prev + 2] = dest_port_num[15:8];
    endfunction
    
    
    
    // Append PTP header to the reference frame_data[] dynamic array
    virtual function void insert_ptp_header(ref bit [7:0] frame_data[], input bit [3:0] message_type, input bit two_step_flag);
        int unsigned i;
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 34](frame_data);
        
        // assign random values (DD) to all 34 bytes
        for(i = 0; i < 34; i++) begin
            frame_data[frame_data_size_prev + i] = 8'hDD;
        end
        
        // insert message type (replace random value)
        frame_data[frame_data_size_prev + 0] = message_type[7:0];
        
		 //insert msg flag (replace random value)
		 frame_data[frame_data_size_prev + 7][1] = two_step_flag;      
    endfunction
    
    
    
    // Append PTP header to the reference frame_data[] dynamic array
    virtual function void insert_ptp_content(ref bit [7:0] frame_data[]);
        int unsigned i;
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 20](frame_data);
        
        for(i = 0; i < 10; i++) begin
            frame_data[frame_data_size_prev + i] = 8'hFF;
        end
    endfunction
    
    
    
    // Append payload data to the reference frame_data[] dynamic array
    virtual function void insert_payload(ref bit [7:0] frame_data[], input bit [7:0] payload[]);
        int unsigned i;
        int unsigned payload_size;
        
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        payload_size = payload.size();
        
        frame_data = new[frame_data_size_prev + payload_size](frame_data);
        
        for(i = 0; i < payload_size; i++) begin
            frame_data[frame_data_size_prev + i] = payload[i];
        end
    endfunction
    
    
    
    // Append calculated CRC to the reference frame_data[] dynamic array
    virtual function void insert_crc(ref bit [7:0] frame_data[], input bit [31:0] crc);
        int unsigned frame_data_size_prev;
        frame_data_size_prev = frame_data.size();
        
        frame_data = new[frame_data_size_prev + 4](frame_data);
        
        frame_data[frame_data_size_prev + 0] = crc[7:0];
        frame_data[frame_data_size_prev + 1] = crc[15:8];
        frame_data[frame_data_size_prev + 2] = crc[23:16];
        frame_data[frame_data_size_prev + 3] = crc[31:24];
    endfunction
    
    
    
    bit pfc_error = 0;
    bit [7:0] pfc_priority_ena;
    bit [15:0] pfc_pause_quanta[7:0];
    bit [1:0] vlan_tag;
    
    bit ipv4_header;
    bit ipv6_header;
    bit udp_header;
    
    bit ptp_ethernet;
    bit ptp_udp;
    
    bit ptp_event;

    bit [63:0] ptp_correction_field;
    bit [79:0] ptp_timestamp;
    
    bit [3:0]  ptp_message_type;
    bit        ptp_message_flag;
	bit		   insert_tstamp;
	bit		   insert_rt;
    bit [1:0]  clock_mode;
    bit        short_frame;
    bit [15:0]  udp_port;
        bit [7:0] length_type_offset;
        bit [7:0] ip_header_offset;
        bit [7:0] udp_header_offset;
        bit [7:0] ptp_header_offset;

        
    virtual function void analyze_frame(bit [1:0] clock_mode);

		this.clock_mode = clock_mode;
        
        // Check for VLAN tagged
        if({frame_content[12], frame_content[13]} == LENGTH_TYPE_VLAN) begin
            if({frame_content[16], frame_content[17]} == LENGTH_TYPE_VLAN) begin
                vlan_tag = 2;
            end
            else begin
                vlan_tag = 1;
            end
        end
        else begin
            vlan_tag = 0;
        end
        
        length_type_offset = 12 + vlan_tag * 4;              
        
        // Check for IEEE 802.3 PTP
        if({frame_content[length_type_offset], frame_content[length_type_offset + 1]} == LENGTH_TYPE_PTP) begin
            ptp_ethernet = 1;
            ptp_header_offset = length_type_offset + 2;
        end
        else begin
            ptp_ethernet = 0;
        end
        
        // Check for IPv4 Header
        if({frame_content[length_type_offset], frame_content[length_type_offset + 1]} == LENGTH_TYPE_IPV4) begin
            ipv4_header = 1;
            ip_header_offset = length_type_offset + 2;
        end
        else begin
            ipv4_header = 0;
        end
               
        // Check for IPv6 Header
        if({frame_content[length_type_offset], frame_content[length_type_offset + 1]} == LENGTH_TYPE_IPV6) begin
            ipv6_header = 1;
            ip_header_offset = length_type_offset + 2;
        end
        else begin
            ipv6_header = 0;
        end
        
        
        
        udp_header = 0;
        // Check for UDP/IPv4 Header
        if(ipv4_header && {frame_content[ip_header_offset + 9]} == PROTOCOL_UDP) begin
            udp_header = 1;
            udp_header_offset = ip_header_offset + 20;
        end
              
        // Check for UDP/IPv6 Header
        if(ipv6_header && {frame_content[ip_header_offset + 6]} == PROTOCOL_UDP) begin
            udp_header = 1;
            udp_header_offset = ip_header_offset + 40;
        end
    
        // Check for PTP UDP/IP Port
        if(udp_header && ({frame_content[udp_header_offset + 2], frame_content[udp_header_offset + 3]} == UDP_PORT_PTP_EVENT) ) begin
            udp_port = UDP_PORT_PTP_EVENT;
            ptp_udp = 1;
            ptp_header_offset = udp_header_offset + 8;
        end
        else if(udp_header &&  ({frame_content[udp_header_offset + 2], frame_content[udp_header_offset + 3]} == UDP_PORT_PTP_MISC) ) begin
            udp_port = UDP_PORT_PTP_MISC;
            ptp_udp = 1;
            ptp_header_offset = udp_header_offset + 8;
        end
        else begin
            ptp_udp = 0;
        end
        
        
        
        
        // Check for PTP Event
        if(ptp_ethernet || ptp_udp) begin
            ptp_event = !(frame_content[ptp_header_offset][3]);
        end
 
        // Extract PTP Content - correction field (fns) and timestamp(s and ns)
        if(ptp_ethernet || ptp_udp) begin
            ptp_correction_field = {frame_content[ptp_header_offset + 8 + 0],
                                    frame_content[ptp_header_offset + 8 + 1],
                                    frame_content[ptp_header_offset + 8 + 2],
                                    frame_content[ptp_header_offset + 8 + 3],
                                    frame_content[ptp_header_offset + 8 + 4],
                                    frame_content[ptp_header_offset + 8 + 5],
                                    frame_content[ptp_header_offset + 8 + 6],
                                    frame_content[ptp_header_offset + 8 + 7]};
            
            ptp_timestamp        = {frame_content[ptp_header_offset + 34 + 0],
                                    frame_content[ptp_header_offset + 34 + 1],
                                    frame_content[ptp_header_offset + 34 + 2],
                                    frame_content[ptp_header_offset + 34 + 3],
                                    frame_content[ptp_header_offset + 34 + 4],
                                    frame_content[ptp_header_offset + 34 + 5],
                                    frame_content[ptp_header_offset + 34 + 6],
                                    frame_content[ptp_header_offset + 34 + 7],
                                    frame_content[ptp_header_offset + 34 + 8],
                                    frame_content[ptp_header_offset + 34 + 9]};
        end
        else begin
            ptp_correction_field = 0;
            ptp_timestamp = 0;
        end
     
        // Extract PTP Content - msg type and msg flag
		if ((ipv4_header == 1 || ipv6_header == 1) && (udp_header == 0 || ptp_udp == 0)) begin
			ptp_message_type = 4'h4;
			ptp_message_flag = 1'h0;		
		end else begin
			ptp_message_type = frame_content[ptp_header_offset + 0][3:0];
			ptp_message_flag = frame_content[ptp_header_offset + 7][1];
		end


		if (clock_mode == ORDINARY_CLOCK || clock_mode == BOUNDARY_CLOCK) begin
			if (ptp_message_type == MSG_SYNC && ptp_message_flag == 1'b0 && (ptp_ethernet || ptp_udp)) begin
				insert_tstamp = 1'b1;
				insert_rt = 1'b0;
			end	else if (ptp_message_type == MSG_PDELAY_RESP && ptp_message_flag == 1'b0 && (ptp_ethernet || ptp_udp)) begin
				insert_tstamp = 1'b0;
				insert_rt = 1'b1;
			end					
		end

		if (clock_mode == E2E_TRANSPARENT_CLOCK) begin				
			if (ptp_message_type == MSG_SYNC || ptp_message_type == MSG_DELAY_REQ || ptp_message_type == MSG_PDELAY_RESP || ptp_message_type == MSG_PDELAY_REQ && (ptp_ethernet || ptp_udp)) begin
				insert_tstamp = 1'b0;
				insert_rt = 1'b1;
			end					
		end	

		if (clock_mode == P2P_TRANSPARENT_CLOCK) begin				
			if (ptp_message_type == MSG_SYNC || ptp_message_type == MSG_DELAY_REQ || (ptp_message_type == MSG_PDELAY_RESP && ptp_message_flag == 1'b0) && (ptp_ethernet || ptp_udp)) begin
				insert_tstamp = 1'b0;
				insert_rt = 1'b1;
			end					
		end	
        
        
        
        
        
    endfunction
endclass

`endif
