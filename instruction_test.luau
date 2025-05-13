-- Custom Instruction Test Suite by Heftig_HD
return {
	test = {
		AND = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_111_00011_0110011);
			buffer.writeu32(XREGS, 4, 0xF0F0F0F0);
			buffer.writeu32(XREGS, 8, 0x0F0F0F0F);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 0;
		end,
		SLT = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_010_00011_0110011);
			buffer.writeu32(XREGS, 4, 10);
			buffer.writeu32(XREGS, 8, 20);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 1;
		end,
		ADD = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0x002081B3);
			buffer.writeu32(XREGS, 4, 5);
			buffer.writeu32(XREGS, 8, 7);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 12;
		end,
		SUB = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0100000_00111_01000_000_00110_0110011);
			buffer.writeu32(XREGS, 28, 20); 
			buffer.writeu32(XREGS, 32, 10);
			cycle_cpu();
			return buffer.readi32(XREGS, 24) == -10;
		end,
		LUI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b00100000000000000000_00110_0110111);
			cycle_cpu();
			return buffer.readu32(XREGS, 24) == 0x20000000;
		end,
		OR = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00111_01000_110_00110_0110011);
			buffer.writeu32(XREGS, 28, 0xFFFF0000);
			buffer.writeu32(XREGS, 32, 0x00FF00FF);
			cycle_cpu();
			return buffer.readu32(XREGS, 24) == 0xFFFF00FF;
		end,
		XOR = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00111_01000_100_00110_0110011);
			buffer.writeu32(XREGS, 28, 0b01);
			buffer.writeu32(XREGS, 32, 0b10); 
			cycle_cpu();
			return buffer.readu32(XREGS, 24) == 0b11;
		end,
		JAL = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000000001_000000000001_00001_1101111);
			cycle_cpu();
			return buffer.readu32(XREGS, 4) == 0x4;
		end,
		JALR = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000000100_00001_000_00010_1100111);
			buffer.writeu32(XREGS, 4, 0x1000);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 4 and buffer.readu32(XREGS, 128) == 0x1004;
		end,
		AUIPC = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b00000000000000000001_00001_0010111);
			cycle_cpu();
			return buffer.readu32(XREGS, 4) == 4100;
		end,
		LB = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(XREGS, 4, 256);
			buffer.writeu32(ram, 257, 255);
			buffer.writeu32(ram, 0, 0b000000000001_00001_000_00010_0000011);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 0xFFFFFFFF;
		end,
		LH = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(XREGS, 4, 256);
			buffer.writeu32(ram, 257, 111);
			buffer.writeu32(ram, 0, 0b000000000001_00001_001_00010_0000011);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 111;
		end,
		LW = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(XREGS, 4, 256);
			buffer.writeu32(ram, 257, 111);
			buffer.writeu32(ram, 0, 0b000000000001_00001_010_00010_0000011);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 111;
		end,
		LBU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(XREGS, 4, 256);
			buffer.writeu32(ram, 257, 111);
			buffer.writeu32(ram, 0, 0b000000000001_00001_100_00010_0000011);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 111;
		end,
		LHU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(XREGS, 4, 256);
			buffer.writeu32(ram, 257, 111);
			buffer.writeu32(ram, 0, 0b000000000001_00001_101_00010_0000011);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 111;
		end,
		LWU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(XREGS, 4, 256);
			buffer.writeu32(ram, 257, 111);
			buffer.writeu32(ram, 0, 0b000000000001_00001_110_00010_0000011);
			cycle_cpu();
			return buffer.readu32(XREGS, 8) == 111;
		end,
		SLTIU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000001111_00111_011_00110_0010011);
			buffer.writeu32(XREGS, 7 * 4, 5);
			cycle_cpu();
			return buffer.readu32(XREGS, 6 * 4) == 1;
		end,
		SLL = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_001_00011_0110011);
			buffer.writeu32(XREGS, 4, 1);
			buffer.writeu32(XREGS, 8, 3);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 8;
		end,
		SRA = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0100000_00010_00001_101_00011_0110011);
			buffer.writeu32(XREGS, 4, 0x80000000);
			buffer.writeu32(XREGS, 8, 1);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 0xC0000000;
		end,
		SLTU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_011_00011_0110011);
			buffer.writeu32(XREGS, 4, 10);
			buffer.writeu32(XREGS, 8, 20);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 1;
		end,
		SRL = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_101_00011_0110011);
			buffer.writeu32(XREGS, 4, 64);
			buffer.writeu32(XREGS, 8, 3);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 8;
		end,
		MUL = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_000_00011_0110011);
			buffer.writeu32(XREGS, 4, 5);
			buffer.writeu32(XREGS, 8, 4);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 20;
		end,
		--[[MULH = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_001_00011_0110011);
			buffer.writeu32(XREGS, 4, 0x80000000);
			buffer.writeu32(XREGS, 8, 2);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 0x80000000;
		end,
		MULHSU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_001_00011_0110011);
			buffer.writeu32(XREGS, 4, 0x80000000); 
			buffer.writeu32(XREGS, 8, 2); 
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 0x80000000; 
		end,
		MULHU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_001_00011_0110011); 
			buffer.writeu32(XREGS, 4, 0x80000000);
			buffer.writeu32(XREGS, 8, 2);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 0x80000000;
		end,]]
		DIV = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_100_00011_0110011); 
			buffer.writeu32(XREGS, 4, 20);
			buffer.writeu32(XREGS, 8, -4); 
			cycle_cpu();
			return buffer.readi32(XREGS, 12) == -5;
		end,
		DIVU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_101_00011_0110011); 
			buffer.writeu32(XREGS, 4, 20);
			buffer.writeu32(XREGS, 8, 4); 
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 5;
		end,
		REM = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_110_00011_0110011); 
			buffer.writeu32(XREGS, 4, 4);
			buffer.writeu32(XREGS, 8, -5); 
			cycle_cpu();
			return buffer.readi32(XREGS, 12) == -1;
		end,
		REMU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000001_00010_00001_111_00011_0110011); 
			buffer.writeu32(XREGS, 4, 20);
			buffer.writeu32(XREGS, 8, 4); 
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 0;
		end,


		ADDI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000000111_00010_000_00001_0010011);
			buffer.writei32(XREGS, 8, -8);
			cycle_cpu();
			return buffer.readi32(XREGS, 4) == -1;
		end,
		SRAI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000100000_00001_00001_101_00011_0010011);
			buffer.writeu32(XREGS, 4, 5);
			cycle_cpu();
			return buffer.readu32(XREGS, 12) == 2;
		end,
		SRLI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000000001_00010_101_00001_0010011);
			buffer.writeu32(XREGS, 8, 0xF0F0F0F0); 
			cycle_cpu();
			return buffer.readu32(XREGS, 4) == 0x78787878;
		end,
		SLTI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000001111_00111_010_00110_0010011); 
			buffer.writeu32(XREGS, 28, 10);
			cycle_cpu();
			return buffer.readu32(XREGS, 24) == 1;
		end,
		SLLI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000000111_00001_001_00010_0010011);
			buffer.writei32(XREGS, 4, -1);
			cycle_cpu();
			return buffer.readi32(XREGS, 8) == -128;
		end,
		XORI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b100000000001_00010_100_00001_0010011);
			buffer.writeu32(XREGS, 8, 1); 
			cycle_cpu();
			return buffer.readu32(XREGS, 4) == 4294965248;
		end,
		ORI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b000000001111_00010_110_00001_0010011);
			buffer.writeu32(XREGS, 8, 0b1010);
			cycle_cpu();
			return buffer.readu32(XREGS, 4) == 0b1111;
		end,
		ANDI = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b100000001111_00010_111_00001_0010011);
			buffer.writeu32(XREGS, 8, 0b1010);
			cycle_cpu();
			return buffer.readu32(XREGS, 4) == 0b1010;
		end,

		BEQ = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_000_00011_1100011);
			buffer.writeu32(XREGS, 4, 10);  
			buffer.writeu32(XREGS, 8, 10); 
			cycle_cpu();
			return buffer.readu32(XREGS, 128) == 7;
		end,
		BNE = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_001_00011_1100011);
			buffer.writeu32(XREGS, 4, 5);  
			buffer.writeu32(XREGS, 8, 10); 
			cycle_cpu();
			return buffer.readu32(XREGS, 128) == 7;
		end,
		BLT = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_100_00011_1100011);
			buffer.writeu32(XREGS, 4, -5);  
			buffer.writeu32(XREGS, 8, 10); 
			cycle_cpu();
			return buffer.readu32(XREGS, 128) == 7;
		end,
		BGE = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_101_00011_1100011);
			buffer.writeu32(XREGS, 4, 10);  
			buffer.writeu32(XREGS, 8, -5); 
			cycle_cpu();
			return buffer.readu32(XREGS, 128) == 7;
		end,
		BLTU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_110_00011_1100011);
			buffer.writeu32(XREGS, 4, 10);  
			buffer.writeu32(XREGS, 8, -1); 
			cycle_cpu();
			return buffer.readu32(XREGS, 128) == 7;
		end,
		BGEU = function(cycle_cpu: () -> (), ram: buffer, XREGS: buffer): boolean
			buffer.writeu32(ram, 0, 0b0000000_00010_00001_111_00011_1100011);
			buffer.writeu32(XREGS, 4, -1);  
			buffer.writeu32(XREGS, 8, 10); 
			cycle_cpu();
			return buffer.readu32(XREGS, 128) == 7;
		end,
	}
}
