local XREGS: buffer = buffer.create(436);
local ram: buffer = buffer.create(134217728);

local cycle = @native @checked function(): ()
	local len32: number = buffer.readu32(ram, buffer.readu32(XREGS, 128));
	local op7: number = bit32.band(len32, 0x7F);
	if op7 == 0b0000011 or op7 == 0b0000111 or op7 == 0b0010011 or op7 == 0b1100111 or op7 == 0b0011011 or op7 == 0b0101111 then
		-- format: TYPE_I
		local rd: number = len32 // 128 % 32;
		local funct3: number = len32 // 4096 % 8;
		local rs1: number = len32 // 32768 % 32;
		local imm: number = len32 // 1048576 % 4096;
		if op7 == 0b0000011 then
			if funct3 == 0b000 then -- checked
				-- LB
				buffer.writeu32(XREGS, rd * 4, buffer.readi8(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			elseif funct3 == 0b001 then
				-- LH
				buffer.writeu32(XREGS, rd * 4, buffer.readi16(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			elseif funct3 == 0b010 then
				-- LW
				buffer.writeu32(XREGS, rd * 4, buffer.readi32(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			elseif funct3 == 0b011 then
				-- LD
				local addr: number = (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296;
				local rd_offset: number = rd * 4;
				buffer.writeu32(XREGS, rd_offset, buffer.readu32(ram, addr));
				buffer.writeu32(XREGS, rd_offset + 4, buffer.readu32(ram, addr + 4));
			elseif funct3 == 0b100 then
				-- LBU
				buffer.writeu32(XREGS, rd * 4, buffer.readu8(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			elseif funct3 == 0b101 then
				-- LHU
				buffer.writeu32(XREGS, rd * 4, buffer.readu16(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			elseif funct3 == 0b110 then
				-- LWU
				buffer.writeu32(XREGS, rd * 4, buffer.readu32(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			end;
		elseif op7 == 0b0000111 then -- checked
			if funct3 == 0b010 then
				-- FLW
				buffer.writef32(XREGS, rd * 4, buffer.readf32(ram, (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296));
			elseif funct3 == 0b011 then
				-- FLD
				local addr: number = (buffer.readu32(XREGS, rs1 * 4) + imm) % 4294967296;
				local rd_offset: number = rd * 4;
				buffer.writeu32(XREGS, rd_offset, buffer.readu32(ram, addr));
				buffer.writeu32(XREGS, rd_offset + 4, buffer.readu32(ram, addr + 4));
			end;
		elseif op7 == 0b0010011 then -- checked
			if funct3 == 0b000 then
				-- ADDI
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				local result: number = buffer.readu32(XREGS, rs1 * 4) + imm;
				result %= (result < 0 and -4294967296) or 4294967296;
				buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) + imm));
			elseif funct3 == 0b001 then
				-- SLLI
				buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) * (2 ^ (imm % 32))) % 4294967296);
			elseif funct3 == 0b010 then
				-- SLTI
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				buffer.writeu32(XREGS, rd * 4, buffer.readi32(XREGS, rs1 * 4) < imm and 1 or 0)
			elseif funct3 == 0b011 then
				-- SLTIU
				buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, rs1 * 4) < imm and 1 or 0);
			elseif funct3 == 0b100 then
				-- XORI
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				buffer.writeu32(XREGS, rd * 4, bit32.bxor(buffer.readu32(XREGS, rs1 * 4), imm));
			elseif funct3 == 0b101 then
				-- SRLI/SRAI
				if imm // 32 == 0x20 then
					buffer.writeu32(XREGS, rd * 4, bit32.arshift(buffer.readu32(XREGS, rs1 * 4), imm % 32) % 4294967296);
				else
					buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, rs1 * 4) // (2 ^ (imm % 32)));
				end;
			elseif funct3 == 0b110 then
				-- ORI
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				buffer.writeu32(XREGS, rd * 4, bit32.bor(buffer.readu32(XREGS, rs1 * 4), imm));
			elseif funct3 == 0b111 then
				-- ANDI
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				buffer.writeu32(XREGS, rd * 4, bit32.band(buffer.readu32(XREGS, rs1 * 4), imm));
			end;
		elseif op7 == 0b1100111 then
			if funct3 == 0b000 then
				-- JALR (JALRW in rv64i) !!TEST THIS INSTRUCTION!! i tested it :3
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				local result: number = buffer.readu32(XREGS, rs1 * 4) + imm - 4;
				result %= (result < 0 and -4294967296) or 4294967296;
				buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, 128) + 4) % 4294967296);
				buffer.writeu32(XREGS, 128, result);
			end;
		elseif op7 == 0b1101011 then
			if funct3 == 0b000 or funct3 == 0b001 or funct3 == 0b010 then -- JALR.C/R/J
				if imm >= 0x800 then
					imm -= 0x1000;
				end;
				local result: number = buffer.readu32(XREGS, rs1 * 4) + imm;
				result %= (result < 0 and -4294967296) or 4294967296;
				buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, 128) + 4) % 4294967296);
				buffer.writeu32(XREGS, 128, bit32.band(result, 0xFFFFFFFE));
			elseif funct3 == 0b100 then -- RDNPC
				buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, 128));
			end;
		elseif op7 == 0b0011011 then
			if funct3 == 0b000 then
				-- ADDIW

			elseif funct3 == 0b001 then
				-- SLLIW

			elseif funct3 == 0b101 then
				local shamt: number = imm % 32;
				local imm7: number = imm // 32;
				if imm7 == 0b0000000 then
					-- SRLIW

				elseif imm7 == 0b0000010 then
					-- SRAIW

				end;
			end;
		elseif op7 == 0b0101111 then -- Miscellaneous Memory Instructions
			if funct3 == 0b001 then
				-- FENCE.I

			elseif funct3 == 0b010 then
				-- FENCE

			end;
		end;
	elseif op7 == 0b1000011 or op7 == 0b1000111 or op7 == 0b1001011 or op7 == 0b1001111 then
		-- format: TYPE_FNM
		local rd: number, rm: number, rs1: number, rs2: number, w: number, rs3: number = len32 // 128 % 32, len32 // 4096 % 8, len32 // 32768 % 32, len32 // 1048576 % 32, len32 // 33554432 % 4, len32 // 134217728 % 32;

		if op7 == 0b1000011 then
			if w == 0b00 then
				-- FMADD_S
				buffer.writef32(XREGS, rd * 4, (buffer.readf32(XREGS, rs1 * 4) * buffer.readf32(XREGS, rs2 * 4)) + buffer.readf32(XREGS, rs3 * 4));
			else
				-- FMADD_D
				buffer.writef64(XREGS, rd * 8, (buffer.readf64(XREGS, rs1 * 8) * buffer.readf64(XREGS, rs2 * 8)) + buffer.readf64(XREGS, rs3 * 8));
			end;
		elseif op7 == 0b1000111 then
			if w == 0b00 then
				-- FMSUB_S
				buffer.writef32(XREGS, rd * 4, (buffer.readf32(XREGS, rs1 * 4) * buffer.readf32(XREGS, rs2 * 4)) - buffer.readf32(XREGS, rs3 * 4));
			else
				-- FMSUB_D
				buffer.writef64(XREGS, rd * 8, (buffer.readf64(XREGS, rs1 * 8) * buffer.readf64(XREGS, rs2 * 8)) - buffer.readf64(XREGS, rs3 * 8));
			end;
		elseif op7 == 0b1001011 then
			if w == 0b00 then
				-- FNMSUB_S
				buffer.writef32(XREGS, rd * 4, -(buffer.readf32(XREGS, rs1 * 4) * buffer.readf32(XREGS, rs2 * 4)) - buffer.readf32(XREGS, rs3 * 4));
			else
				-- FNMSUB_D
				buffer.writef64(XREGS, rd * 8, -(buffer.readf64(XREGS, rs1 * 8) * buffer.readf64(XREGS, rs2 * 8)) - buffer.readf64(XREGS, rs3 * 8));
			end;
		elseif op7 == 0b1001111 then -- five pm meowing
			if w == 0b00 then
				-- FNMADD_S
				buffer.writef32(XREGS, rd * 4, -(buffer.readf32(XREGS, rs1 * 4) * buffer.readf32(XREGS, rs2 * 4)) + buffer.readf32(XREGS, rs3 * 4));
			else
				-- FNMADD_D
				buffer.writef64(XREGS, rd * 8, -(buffer.readf64(XREGS, rs1 * 8) * buffer.readf64(XREGS, rs2 * 8)) + buffer.readf64(XREGS, rs3 * 8));
			end;
		end;
	elseif op7 == 0b1100011 then
		-- TYPE_B
		local imm5: number, funct3: number, rs1: number, rs2: number, imm7: number = len32 // 128 % 32, len32 // 4096 % 8, len32 // 32768 % 32, len32 // 1048576 % 32, len32 // 33554432 % 128;
		if funct3 == 0b000 and buffer.readi32(XREGS, rs1 * 4) == buffer.readi32(XREGS, rs2 * 4) then
			-- BEQ
			buffer.writeu32(XREGS, 128, imm7 * 32 + imm5);
		elseif funct3 == 0b001 and buffer.readi32(XREGS, rs1 * 4) ~= buffer.readi32(XREGS, rs2 * 4) then
			-- BNE
			buffer.writeu32(XREGS, 128, imm7 * 32 + imm5);
		elseif funct3 == 0b100 and buffer.readi32(XREGS, rs1 * 4) < buffer.readi32(XREGS, rs2 * 4) then
			-- BLT
			buffer.writeu32(XREGS, 128, imm7 * 32 + imm5);
		elseif funct3 == 0b101 and buffer.readi32(XREGS, rs1 * 4) >= buffer.readi32(XREGS, rs2 * 4) then
			-- BGE
			buffer.writeu32(XREGS, 128, imm7 * 32 + imm5);
		elseif funct3 == 0b110 and buffer.readu32(XREGS, rs1 * 4) < buffer.readu32(XREGS, rs2 * 4) then
			-- BLTU
			buffer.writeu32(XREGS, 128, imm7 * 32 + imm5);
		elseif funct3 == 0b111 and buffer.readu32(XREGS, rs1 * 4) >= buffer.readu32(XREGS, rs2 * 4) then
			-- BGEU
			buffer.writeu32(XREGS, 128, imm7 * 32 + imm5);
		elseif funct3 == 0b010 then
			-- FSW TODO
		elseif funct3 == 0b011 then
			-- FSD TODO
		end;
	elseif op7 == 0b1010011 or (op7 >= 0b1000011 and op7 <= 0b1001111) then
		local encoding: number = len32 // 128 % 4;
		local rm: number = len32 // 512 % 32;
		local funct5: number = len32 // 4096 % 32;
		if op7 == 0b1010011 then
			if encoding == 0b00 then
				if funct5 == 0b00000 then
					-- FADD.S

				elseif funct5 == 0b00001 then
					-- FSUB.S

				elseif funct5 == 0b00010 then
					-- FMUL.S

				elseif funct5 == 0b00011 then
					-- FDIV.S

				elseif funct5 == 0b11000 then
					-- FMIN.S

				elseif funct5 == 0b11001 then
					-- FMAX.S
				
				elseif funct5 == 0b00101 then
					-- FSGNJ.S
					
				elseif funct5 == 0b00110 then
					-- FSGNJN.S
					
				elseif funct5 == 0b00111 then
					-- FSGNJX.S 
					
				elseif funct5 == 0b10001 then
					-- FCVT.S.D
				
				elseif funct5 == 0b01100 then
					-- FCVT.S.L

				elseif funct5 == 0b01101 then
					-- FCVT.S.LU

				elseif funct5 == 0b01110 then
					-- FCVT.S.W

				elseif funct5 == 0b01111 then
					-- FCVT.S.WU
					
				elseif funct5 == 0b11110 then
					-- MXTF.S
				
				elseif funct5 == 0b11111 then
					-- MTFSR
				
				elseif funct5 == 0b01000 then
					-- FCVT.L.S

				elseif funct5 == 0b01001 then
					-- FCVT.LU.S

				elseif funct5 == 0b01010 then
					--  FCVT.W.S

				elseif funct5 == 0b01011 then
					-- FCVT.WU.S
					
				elseif funct5 == 0b11100 then
					-- MFTX.S
				
				elseif funct5 == 0b11101 then
					-- MFFSR.S
					
				elseif funct5 == 0b10101 then
					-- FEQ.S
				
				elseif funct5 == 0b10110 then
					-- FLT.S
				
				elseif funct5 == 0b10111 then
					-- FLE.S
					
				end;
			elseif encoding == 0b01 then
				if funct5 == 0b00000 then
					-- FADD.D

				elseif funct5 == 0b00001 then
					-- FSUB.D

				elseif funct5 == 0b00010 then
					-- FMUL.D

				elseif funct5 == 0b00011 then
					-- FDIV.D

				elseif funct5 == 0b11000 then
					-- FMIN.D

				elseif funct5 == 0b11001 then
					-- FMAX.D
					
				elseif funct5 == 0b00101 then
					-- FSGNJ.D

				elseif funct5 == 0b00110 then
					-- FSGNJN.D

				elseif funct5 == 0b00111 then
					-- FSGNJX.D
					
				elseif funct5 == 0b10000 then
					-- FCVT.D.S
				
				elseif funct5 == 0b01100 then
					-- FCVT.D.L

				elseif funct5 == 0b01101 then
					-- FCVT.D.LU

				elseif funct5 == 0b01110 then
					-- FCVT.D.W

				elseif funct5 == 0b01111 then
					-- FCVT.D.WU
				
				elseif funct5 == 0b11110 then
					-- MXTF.D
					
				elseif funct5 == 0b01000 then
					-- FCVT.L.D
					
				elseif funct5 == 0b01001 then
					-- FCVT.LU.D
					
				elseif funct5 == 0b01010 then
					--  FCVT.W.D
					
				elseif funct5 == 0b01011 then
					-- FCVT.WU.D
				
				elseif funct5 == 0b11100 then
					-- MFTX.D
					
				elseif funct5 == 0b10101 then
					-- FEQ.D

				elseif funct5 == 0b10110 then
					-- FLT.D

				elseif funct5 == 0b10111 then
					-- FLE.D
				
				end;
			end;
		elseif op7 == 0b1000011 then
			if encoding == 0b00 then
				-- FMADD.S
				
			elseif encoding == 0b01 then
				-- FMADD.D
				
			end;
		elseif op7 == 0b1000111 then
			if encoding == 0b00 then
				-- FMSUB.S
				
			elseif encoding == 0b01 then
				-- FMSUB.D
				
			end;
		elseif op7 == 0b1001011 then
			if encoding == 0b00 then
				-- FNMSUB.S
				
			elseif encoding == 0b01 then
				-- FNMSUB.D
				
			end;
		elseif op7 == 0b1001111 then
			if encoding == 0b00 then
				-- FNMADD.S
				
			elseif encoding == 0b01 then
				-- FNMADD.D
				
			end;
		end;
	elseif op7 == 0b0110011 or op7 == 0b0101011 or op7 == 0b0111011 then
		-- format: TYPE_R
		local funct3: number = len32 // 128 % 8;
		local funct7: number = len32 // 1028 % 128;
		local rs2: number = len32 // 131072 % 32;
		local rs1: number = len32 // 4194304 % 32;
		local rd: number = len32 // 134217728;
		if op7 == 0b0110011 then
			if funct7 == 0b0000000 then
				if funct3 == 0b000 then
					-- ADD
					buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) + buffer.readu32(XREGS, rs2 * 4)) % 4294967296);
				elseif funct3 == 0b001 then
					-- SLL
					buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) * (2 ^ bit32.band(buffer.readu32(XREGS, rs2 * 4), 0x1F))) % 4294967296);
				elseif funct3 == 0b010 then
					-- SLT (Set Less Than) - Signed comparison
					buffer.writeu32(XREGS, rd * 4, (buffer.readi32(XREGS, rs1 * 4) < buffer.readi32(XREGS, rs2 * 4)) and 1 or 0);
				elseif funct3 == 0b011 then
					-- SLTU
					buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) < buffer.readu32(XREGS, rs2 * 4)) and 1 or 0);
				elseif funct3 == 0b100 then
					-- XOR
					buffer.writeu32(XREGS, rd * 4, bit32.bxor(buffer.readu32(XREGS, rs1 * 4), buffer.readu32(XREGS, rs2 * 4)));
				elseif funct3 == 0b101 then
					-- SRL
					buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, rs1 * 4) // 2 ^ bit32.band(buffer.readu32(XREGS, rs2 * 4), 0x1F));
				elseif funct3 == 0b110 then
					-- OR
					buffer.writeu32(XREGS, rd * 4, bit32.bor(buffer.readu32(XREGS, rs1 * 4), buffer.readu32(XREGS, rs2 * 4)));
				elseif funct3 == 0b111 then
					-- AND
					buffer.writeu32(XREGS, rd * 4, bit32.band(buffer.readu32(XREGS, rs1 * 4), buffer.readu32(XREGS, rs2 * 4)));
				end
			elseif funct7 == 0b0100000 then
				if funct3 == 0b000 then
					-- SUB
					buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, rs1 * 4) - buffer.readu32(XREGS, rs2 * 4));
				elseif funct3 == 0b101 then
					-- SRA 
					buffer.writeu32(XREGS, rd * 4, bit32.arshift(buffer.readu32(XREGS, rs1 * 4), bit32.band(buffer.readu32(XREGS, rs2 * 4), 0x1F)));
				end
			elseif funct7 == 0b0000001 then
				if funct3 == 0b000 then
					-- MUL 
					buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) * buffer.readu32(XREGS, rs2 * 4)) % 4294967296);
				elseif funct3 == 0b001 then
					-- MULH
					buffer.writei32(XREGS, rd * 4, (buffer.readi32(XREGS, rs1 * 4) * buffer.readi32(XREGS, rs2 * 4)) // 4294967296);
				elseif funct3 == 0b010 then
					-- MULHSU 
					buffer.writei32(XREGS, rd * 4, (buffer.readi32(XREGS, rs1 * 4) * buffer.readu32(XREGS, rs2 * 4)) // 4294967296);
				elseif funct3 == 0b011 then
					-- MULHU
					buffer.writeu32(XREGS, rd * 4, (buffer.readu32(XREGS, rs1 * 4) * buffer.readu32(XREGS, rs2 * 4)) // 4294967296);
				elseif funct3 == 0b100 then
					-- DIV 
					local i_rs2: number = buffer.readi32(XREGS, rs2 * 4);
					if i_rs2 == 0 then
						buffer.writei32(XREGS, rd * 4, 0);
					else
						buffer.writei32(XREGS, rd * 4, buffer.readi32(XREGS, rs1 * 4) // i_rs2);
					end;
				elseif funct3 == 0b101 then
					-- DIVU
					local u_rs2: number = buffer.readu32(XREGS, rs2 * 4);
					if u_rs2 == 0 then
						buffer.writeu32(XREGS, rd * 4, 0) ;
					else
						buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, rs1 * 4) // u_rs2)
					end;
				elseif funct3 == 0b110 then
					-- REM
					local i_rs2: number = buffer.readi32(XREGS, rs2 * 4);
					if i_rs2 == 0 then
						buffer.writei32(XREGS, rd * 4, 0);
					else
						buffer.writei32(XREGS, rd * 4, buffer.readi32(XREGS, rs1 * 4) % i_rs2);
					end;
				elseif funct3 == 0b111 then
					-- REMU
					local u_rs2: number = buffer.readu32(XREGS, rs2 * 4);
					if u_rs2 == 0 then
						buffer.writeu32(XREGS, rd * 4, 0);
					else
						buffer.writeu32(XREGS, rd * 4, buffer.readu32(XREGS, rs1 * 4) % u_rs2);
					end;
				end
			end			
		elseif op7 == 0b0101011 then -- Atomic Memory Instructions
			if funct3 == 0b010 then
				if funct7 == 0b0000000 then
					-- AMOADD.W

				elseif funct7 == 0b0000001 then
					-- AMOSWAP.W

				elseif funct7 == 0b0000010 then
					-- AMOAND.W

				elseif funct7 == 0b0000011 then
					-- AMOOR.W

				elseif funct7 == 0b0000100 then
					-- AMOMIN.W

				elseif funct7 == 0b0000101 then
					-- AMOMAX.W

				elseif funct7 == 0b0000110 then
					-- AMOMINU.W

				elseif funct7 == 0b0000111 then
					-- AMOMAXU.W

				end;
			elseif funct3 == 0b011 then
				if funct7 == 0b0000000 then
					-- AMOADD.D

				elseif funct7 == 0b0000001 then
					-- AMOSWAP.D

				elseif funct7 == 0b0000010 then
					-- AMOAND.D

				elseif funct7 == 0b0000011 then
					-- AMOOR.D

				elseif funct7 == 0b0000100 then
					-- AMOMIN.D

				elseif funct7 == 0b0000101 then
					-- AMOMAX.D

				elseif funct7 == 0b0000110 then
					-- AMOMINU.D

				elseif funct7 == 0b0000111 then
					-- AMOMAXU.D

				end;
			end;
		elseif op7 == 0b0111011 then
			if funct3 == 0b000 then
				if funct7 == 0b0000000 then
					-- ADDW

				elseif funct7 == 0b0000001 then
					-- MULW

				elseif funct7 == 0b1000000 then
					-- SUBW

				end;
			elseif funct3 == 0b001 then
				if funct7 == 0b0000000 then
					-- SLLW

				end;
			elseif funct3 == 0b101 then
				if funct7 == 0b0000000 then
					-- SRLW

				elseif funct7 == 0b0000001 then
					-- DIVUW

				elseif funct7 == 0b1000000 then
					-- SRAW

				end;
			elseif funct3 == 0b100 then
				-- DIVW

			elseif funct3 == 0b110 then
				-- REMW

			elseif funct3 == 0b111 then
				-- REMUW

			end;
		end;

	elseif op7 == 0b1101111 or op7 == 0b0110111 then
		-- format: TYPE_J
		local imm25: number = len32 // 128;
		if op7 == 0b1101111 then -- JAL
			if bit32.band(imm25, 16777216) ~= 0 then
				imm25 -= 33554432;
			end;
			buffer.writeu32(XREGS, 4, (buffer.readu32(XREGS, 128) + 4) % 4294967296);
			buffer.writeu32(XREGS, 128, (buffer.readu32(XREGS, 128) + imm25) % 4294967296);
		elseif op7 == 0b1100111 then -- J
			if bit32.band(imm25, 16777216) ~= 0 then
				imm25 -= 33554432;
			end;
			buffer.writeu32(XREGS, 128, (buffer.readu32(XREGS, 128) + imm25) % 4294967296);
		end;
	elseif op7 == 0b0110111 then
		-- format: LUI_TYPE
		local rd: number = len32 // 134217728;
		buffer.writeu32(XREGS, rd * 4, bit32.band(len32 // 128 % 1048576, 0b11111111000000000000));
	elseif op7 == 0b0010111 then
		-- format: U_TYPE
		local rd: number = len32 // 128 % 32; -- AUIPC
		local imm20: number = len32 // 4096 % 1048576;
		buffer.writeu32(XREGS, rd * 4, ((buffer.readu32(XREGS, 128) + 4 + (imm20 * 4096) % 1048576)) % 4294967296);
	elseif op7 == 0b0100011 or op7 == 0b0100111 then
		-- format: TYPE_S
		local imm5: number = len32 // 128 % 32;
		local funct3: number = len32 // 4096 % 8;
		local rs1: number = len32 // 32768 % 32;
		local rs2: number = len32 // 1048576 % 32;
		local imm7: number = len32 // 33554432 % 128;
		if op7 == 0b0100011 then
			if funct3 == 0b000 then
				-- SB
				buffer.writeu8(ram, (buffer.readu32(XREGS, rs1 * 4) + (imm7 * 32 + imm5)) % 4294967296, buffer.readu8(XREGS, rs2));
			elseif funct3 == 0b001 then
				-- SH
				buffer.writeu16(ram, (buffer.readu32(XREGS, rs1 * 4) + (imm7 * 32 + imm5)) % 4294967296, buffer.readu16(XREGS, rs2 * 2));
			elseif funct3 == 0b010 then
				-- SW
				buffer.writeu32(ram, (buffer.readu32(XREGS, rs1 * 4) + (imm7 * 32 + imm5)) % 4294967296, buffer.readu32(XREGS, rs2 * 4));
			elseif funct3 == 0b011 then
				-- SD
				local addr: number = (buffer.readu32(XREGS, rs1 * 4) + (imm7 * 32 + imm5)) % 4294967296;
				local rs2_offset: number = rs2 * 4;
				buffer.writeu32(ram, addr, buffer.readu32(XREGS, rs2_offset));
				buffer.writeu32(ram, addr, buffer.readu32(XREGS, rs2_offset + 4));
			end; -- u calculator :3
		elseif op7 == 0b0100111 then
			if funct3 == 0b010 then
				--buffer.writef32(XREGS, rd * 4, buffer.readf64(ram, (buffer.readu32(XREGS, rs1 * 4) + imm5 + imm7 * 32) % 4294967296));
			elseif funct3 == 0b011 then
				--buffer.writef64(XREGS, rd * 8, buffer.readf64(ram, (buffer.readu32(XREGS, rs1 * 4) + imm5 + imm7 * 32) % 4294967296));
			end;
		end;
	elseif op7 == 0b1110011 then
		-- Special Opcode, Variable Format:
		local D: number = len32 // 1048576 % 4096;
		if D == 0b000000000000 then
			-- ECALL
			warn("wowie a syscall :3", buffer.readu32(XREGS, 68));
		elseif D == 0b000000000001 then
			-- EBREAK
			warn("yippie");
		else
			local zicsr_funct3: number = len32 // 4096 % 8;
			local rd: number = len32 // 128 % 32
			--local funct3: number = len32 // 4096 % 8;
			local rs1: number = len32 // 32768 % 32;
			local csr: number = (len32 // 1048576 % 4096) * 4;
			local imm: number = len32 // 33554432 % 32;
			-- ZICSR FORMAT ^
			if zicsr_funct3 == 0b001 then
				-- CSRRW
				if rd ~= 0 then
					buffer.writeu32(XREGS, rd * 4, buffer.readu32(ram, csr));
				end;
				buffer.writeu32(ram, csr, buffer.readu32(XREGS, rs1 * 4));
			elseif zicsr_funct3 == 0b010 then
				-- CSRRS
				local csr_value: number = buffer.readu32(ram, csr);
				if rd ~= 0 then
					buffer.writeu32(XREGS, rd * 4, csr_value);
				end;
				buffer.writeu32(ram, csr, bit32.bor(csr_value, buffer.readu32(XREGS, rs1 * 4)));
			elseif zicsr_funct3 == 0b011 then
				-- CSRRC
				local csr_value: number = buffer.readu32(ram, csr);
				if rd ~= 0 then
					buffer.writeu32(XREGS, rd * 4, csr_value);
				end;
				buffer.writeu32(ram, csr, bit32.band(csr_value, bit32.bnot(buffer.readu32(XREGS, rs1 * 4))));
			elseif zicsr_funct3 == 0b101 then
				-- CSRRWI
				if rd ~= 0 then
					buffer.writeu32(XREGS, rd * 4, buffer.readu32(ram, csr));
				end;
				buffer.writeu32(ram, csr, bit32.band(buffer.readu32(XREGS, rd * 4), 0x1F));
			elseif zicsr_funct3 == 0b110 then
				-- CSRRSI
				local csr_value: number = buffer.readu32(ram, csr);
				if rd ~= 0 then
					buffer.writeu32(XREGS, rd * 4, csr_value);
				end;
				buffer.writeu32(ram, csr, bit32.bor(csr_value, imm));
			elseif zicsr_funct3 == 0b111 then
				-- CSRRCI
				local csr_value: number = buffer.readu32(ram, csr);
				if rd ~= 0 then
					buffer.writeu32(XREGS, rd * 4, csr_value);
				end;
				buffer.writeu32(ram, csr, bit32.band(csr_value, bit32.bnot(imm)));
			else
				local rd: number = len32 // 128 % 32;
				local funct3: number = len32 // 4096 % 8;
				local rs1: number = len32 // 32768 % 32;
				local rs2: number = len32 // 1048576 % 32;
				local funct7: number = len32 // 33554432;
				-- TYPE_R:
				if funct7 == 0b0001000 then
					if rs2 == 0b00010 then
						-- SRET
						buffer.writeu32(XREGS, 128, buffer.readu32(XREGS, 8) - 4);
					else
						-- WFI
						-- noh
					end;
				elseif funct7 == 0b0011000 then
					-- MRET
					buffer.writeu32(XREGS, 128, buffer.readu32(XREGS, 8) - 4);
				elseif funct7 == 0b0001001 then
					-- SFENCE_VMA
					-- mmm noh
				end;
			end;
		end;
	elseif op7 == 0b1110111 then
		local funct3: number = len32 // 128 % 8;
		-- System Instructions
		if funct3 == 0b000 then
			-- SYSCALL

		elseif funct3 == 0b001 then
			-- BREAK

		elseif funct3 == 0b100 then
			local funct7: number = len32 // 1024 % 128;
			local rd: number = len32 // 134217728;
			if funct7 == 0b0000000 then
				-- RDCYCLE
			elseif funct7 == 0b0000001 then
				-- RDTIME

			elseif funct7 == 0b0000010 then
				-- RDINSTRET

			end;
		end;
	else			
		-- RV32C decoding, pretty much need to redo everything done prior
		-- this should not be considered an optimized portion of the decoder
	end;
	buffer.writeu32(XREGS, 0, 0); -- so goofy
	buffer.writeu32(XREGS, 128, buffer.readu32(XREGS, 128) + 4);
end;

--[[

R4-type
local funct5: number = len32 // 128 % 32;
local rs3: number = len32 // 4096 % 32;
local rs1: number = len32 // 32768 % 32;
local rs2: number = len32 // 131072 % 32;
local rs1: number = len32 // 4194304 % 32;
local rd: number = len32 // 134217728;

J-Type, LUI-Type 5 pm meowing
local imm: number = len32 // 128;

]] 

local tests: {any} = require(script:WaitForChild("instructionTest")).test;
for i: string, v: any in tests do
	buffer.fill(ram, 0, 0, 134217728);
	buffer.fill(XREGS, 0, 0, 436);
	local result: boolean? = v(cycle, ram, XREGS);
	if not result then
		print(i, "incorrect");
		break
	end;
end;
print("done testing")
