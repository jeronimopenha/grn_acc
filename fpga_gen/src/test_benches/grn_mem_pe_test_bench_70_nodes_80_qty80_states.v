

module test_bench_grn_acc_80_mem
(

);


  //Standar I/O signals - Begin
  reg clk;
  reg rst;
  reg start;
  //Standar I/O signals - End

  // grn mem pe instantiation regs and wires - Begin
  reg grn_aws_done_rd_data;
  reg grn_aws_done_wr_data;
  wire grn_aws_request_read;
  reg grn_aws_read_data_valid;
  reg [32-1:0] grn_aws_read_data;
  reg grn_aws_available_write;
  wire grn_aws_request_write;
  wire [32-1:0] grn_aws_write_data;
  wire grn_aws_done;
  // grn mem pe instantiation regs and wires - end

  //Config Rom configuration regs and wires - Begin
  reg [10-1:0] config_counter;
  wire [32-1:0] config_rom [0:494-1];

  //Config Rom configuration - Begin
  assign config_rom[0] = 32'h94100112;
  assign config_rom[1] = 32'h40e03027;
  assign config_rom[2] = 32'hcca22020;
  assign config_rom[3] = 32'hc86baa8c;
  assign config_rom[4] = 32'he00e2ea4;
  assign config_rom[5] = 32'hfee04000;
  assign config_rom[6] = 32'h44413332;
  assign config_rom[7] = 32'h43283c38;
  assign config_rom[8] = 32'h4ae4ee10;
  assign config_rom[9] = 32'h5244aeee;
  assign config_rom[10] = 32'h10010049;
  assign config_rom[11] = 32'hbf952001;
  assign config_rom[12] = 32'h8c93bbb;
  assign config_rom[13] = 32'h2004;
  assign config_rom[14] = 32'h0;
  assign config_rom[15] = 32'h0;
  assign config_rom[16] = 32'h0;
  assign config_rom[17] = 32'h0;
  assign config_rom[18] = 32'h0;
  assign config_rom[19] = 32'h0;
  assign config_rom[20] = 32'h1;
  assign config_rom[21] = 32'h0;
  assign config_rom[22] = 32'h0;
  assign config_rom[23] = 32'h1;
  assign config_rom[24] = 32'h0;
  assign config_rom[25] = 32'h0;
  assign config_rom[26] = 32'h2;
  assign config_rom[27] = 32'h0;
  assign config_rom[28] = 32'h0;
  assign config_rom[29] = 32'h2;
  assign config_rom[30] = 32'h0;
  assign config_rom[31] = 32'h0;
  assign config_rom[32] = 32'h3;
  assign config_rom[33] = 32'h0;
  assign config_rom[34] = 32'h0;
  assign config_rom[35] = 32'h3;
  assign config_rom[36] = 32'h0;
  assign config_rom[37] = 32'h0;
  assign config_rom[38] = 32'h4;
  assign config_rom[39] = 32'h0;
  assign config_rom[40] = 32'h0;
  assign config_rom[41] = 32'h4;
  assign config_rom[42] = 32'h0;
  assign config_rom[43] = 32'h0;
  assign config_rom[44] = 32'h5;
  assign config_rom[45] = 32'h0;
  assign config_rom[46] = 32'h0;
  assign config_rom[47] = 32'h5;
  assign config_rom[48] = 32'h0;
  assign config_rom[49] = 32'h0;
  assign config_rom[50] = 32'h6;
  assign config_rom[51] = 32'h0;
  assign config_rom[52] = 32'h0;
  assign config_rom[53] = 32'h6;
  assign config_rom[54] = 32'h0;
  assign config_rom[55] = 32'h0;
  assign config_rom[56] = 32'h7;
  assign config_rom[57] = 32'h0;
  assign config_rom[58] = 32'h0;
  assign config_rom[59] = 32'h7;
  assign config_rom[60] = 32'h0;
  assign config_rom[61] = 32'h0;
  assign config_rom[62] = 32'h8;
  assign config_rom[63] = 32'h0;
  assign config_rom[64] = 32'h0;
  assign config_rom[65] = 32'h8;
  assign config_rom[66] = 32'h0;
  assign config_rom[67] = 32'h0;
  assign config_rom[68] = 32'h9;
  assign config_rom[69] = 32'h0;
  assign config_rom[70] = 32'h0;
  assign config_rom[71] = 32'h9;
  assign config_rom[72] = 32'h0;
  assign config_rom[73] = 32'h0;
  assign config_rom[74] = 32'ha;
  assign config_rom[75] = 32'h0;
  assign config_rom[76] = 32'h0;
  assign config_rom[77] = 32'ha;
  assign config_rom[78] = 32'h0;
  assign config_rom[79] = 32'h0;
  assign config_rom[80] = 32'hb;
  assign config_rom[81] = 32'h0;
  assign config_rom[82] = 32'h0;
  assign config_rom[83] = 32'hb;
  assign config_rom[84] = 32'h0;
  assign config_rom[85] = 32'h0;
  assign config_rom[86] = 32'hc;
  assign config_rom[87] = 32'h0;
  assign config_rom[88] = 32'h0;
  assign config_rom[89] = 32'hc;
  assign config_rom[90] = 32'h0;
  assign config_rom[91] = 32'h0;
  assign config_rom[92] = 32'hd;
  assign config_rom[93] = 32'h0;
  assign config_rom[94] = 32'h0;
  assign config_rom[95] = 32'hd;
  assign config_rom[96] = 32'h0;
  assign config_rom[97] = 32'h0;
  assign config_rom[98] = 32'he;
  assign config_rom[99] = 32'h0;
  assign config_rom[100] = 32'h0;
  assign config_rom[101] = 32'he;
  assign config_rom[102] = 32'h0;
  assign config_rom[103] = 32'h0;
  assign config_rom[104] = 32'hf;
  assign config_rom[105] = 32'h0;
  assign config_rom[106] = 32'h0;
  assign config_rom[107] = 32'hf;
  assign config_rom[108] = 32'h0;
  assign config_rom[109] = 32'h0;
  assign config_rom[110] = 32'h10;
  assign config_rom[111] = 32'h0;
  assign config_rom[112] = 32'h0;
  assign config_rom[113] = 32'h10;
  assign config_rom[114] = 32'h0;
  assign config_rom[115] = 32'h0;
  assign config_rom[116] = 32'h11;
  assign config_rom[117] = 32'h0;
  assign config_rom[118] = 32'h0;
  assign config_rom[119] = 32'h11;
  assign config_rom[120] = 32'h0;
  assign config_rom[121] = 32'h0;
  assign config_rom[122] = 32'h12;
  assign config_rom[123] = 32'h0;
  assign config_rom[124] = 32'h0;
  assign config_rom[125] = 32'h12;
  assign config_rom[126] = 32'h0;
  assign config_rom[127] = 32'h0;
  assign config_rom[128] = 32'h13;
  assign config_rom[129] = 32'h0;
  assign config_rom[130] = 32'h0;
  assign config_rom[131] = 32'h13;
  assign config_rom[132] = 32'h0;
  assign config_rom[133] = 32'h0;
  assign config_rom[134] = 32'h14;
  assign config_rom[135] = 32'h0;
  assign config_rom[136] = 32'h0;
  assign config_rom[137] = 32'h14;
  assign config_rom[138] = 32'h0;
  assign config_rom[139] = 32'h0;
  assign config_rom[140] = 32'h15;
  assign config_rom[141] = 32'h0;
  assign config_rom[142] = 32'h0;
  assign config_rom[143] = 32'h15;
  assign config_rom[144] = 32'h0;
  assign config_rom[145] = 32'h0;
  assign config_rom[146] = 32'h16;
  assign config_rom[147] = 32'h0;
  assign config_rom[148] = 32'h0;
  assign config_rom[149] = 32'h16;
  assign config_rom[150] = 32'h0;
  assign config_rom[151] = 32'h0;
  assign config_rom[152] = 32'h17;
  assign config_rom[153] = 32'h0;
  assign config_rom[154] = 32'h0;
  assign config_rom[155] = 32'h17;
  assign config_rom[156] = 32'h0;
  assign config_rom[157] = 32'h0;
  assign config_rom[158] = 32'h18;
  assign config_rom[159] = 32'h0;
  assign config_rom[160] = 32'h0;
  assign config_rom[161] = 32'h18;
  assign config_rom[162] = 32'h0;
  assign config_rom[163] = 32'h0;
  assign config_rom[164] = 32'h19;
  assign config_rom[165] = 32'h0;
  assign config_rom[166] = 32'h0;
  assign config_rom[167] = 32'h19;
  assign config_rom[168] = 32'h0;
  assign config_rom[169] = 32'h0;
  assign config_rom[170] = 32'h1a;
  assign config_rom[171] = 32'h0;
  assign config_rom[172] = 32'h0;
  assign config_rom[173] = 32'h1a;
  assign config_rom[174] = 32'h0;
  assign config_rom[175] = 32'h0;
  assign config_rom[176] = 32'h1b;
  assign config_rom[177] = 32'h0;
  assign config_rom[178] = 32'h0;
  assign config_rom[179] = 32'h1b;
  assign config_rom[180] = 32'h0;
  assign config_rom[181] = 32'h0;
  assign config_rom[182] = 32'h1c;
  assign config_rom[183] = 32'h0;
  assign config_rom[184] = 32'h0;
  assign config_rom[185] = 32'h1c;
  assign config_rom[186] = 32'h0;
  assign config_rom[187] = 32'h0;
  assign config_rom[188] = 32'h1d;
  assign config_rom[189] = 32'h0;
  assign config_rom[190] = 32'h0;
  assign config_rom[191] = 32'h1d;
  assign config_rom[192] = 32'h0;
  assign config_rom[193] = 32'h0;
  assign config_rom[194] = 32'h1e;
  assign config_rom[195] = 32'h0;
  assign config_rom[196] = 32'h0;
  assign config_rom[197] = 32'h1e;
  assign config_rom[198] = 32'h0;
  assign config_rom[199] = 32'h0;
  assign config_rom[200] = 32'h1f;
  assign config_rom[201] = 32'h0;
  assign config_rom[202] = 32'h0;
  assign config_rom[203] = 32'h1f;
  assign config_rom[204] = 32'h0;
  assign config_rom[205] = 32'h0;
  assign config_rom[206] = 32'h20;
  assign config_rom[207] = 32'h0;
  assign config_rom[208] = 32'h0;
  assign config_rom[209] = 32'h20;
  assign config_rom[210] = 32'h0;
  assign config_rom[211] = 32'h0;
  assign config_rom[212] = 32'h21;
  assign config_rom[213] = 32'h0;
  assign config_rom[214] = 32'h0;
  assign config_rom[215] = 32'h21;
  assign config_rom[216] = 32'h0;
  assign config_rom[217] = 32'h0;
  assign config_rom[218] = 32'h22;
  assign config_rom[219] = 32'h0;
  assign config_rom[220] = 32'h0;
  assign config_rom[221] = 32'h22;
  assign config_rom[222] = 32'h0;
  assign config_rom[223] = 32'h0;
  assign config_rom[224] = 32'h23;
  assign config_rom[225] = 32'h0;
  assign config_rom[226] = 32'h0;
  assign config_rom[227] = 32'h23;
  assign config_rom[228] = 32'h0;
  assign config_rom[229] = 32'h0;
  assign config_rom[230] = 32'h24;
  assign config_rom[231] = 32'h0;
  assign config_rom[232] = 32'h0;
  assign config_rom[233] = 32'h24;
  assign config_rom[234] = 32'h0;
  assign config_rom[235] = 32'h0;
  assign config_rom[236] = 32'h25;
  assign config_rom[237] = 32'h0;
  assign config_rom[238] = 32'h0;
  assign config_rom[239] = 32'h25;
  assign config_rom[240] = 32'h0;
  assign config_rom[241] = 32'h0;
  assign config_rom[242] = 32'h26;
  assign config_rom[243] = 32'h0;
  assign config_rom[244] = 32'h0;
  assign config_rom[245] = 32'h26;
  assign config_rom[246] = 32'h0;
  assign config_rom[247] = 32'h0;
  assign config_rom[248] = 32'h27;
  assign config_rom[249] = 32'h0;
  assign config_rom[250] = 32'h0;
  assign config_rom[251] = 32'h27;
  assign config_rom[252] = 32'h0;
  assign config_rom[253] = 32'h0;
  assign config_rom[254] = 32'h28;
  assign config_rom[255] = 32'h0;
  assign config_rom[256] = 32'h0;
  assign config_rom[257] = 32'h28;
  assign config_rom[258] = 32'h0;
  assign config_rom[259] = 32'h0;
  assign config_rom[260] = 32'h29;
  assign config_rom[261] = 32'h0;
  assign config_rom[262] = 32'h0;
  assign config_rom[263] = 32'h29;
  assign config_rom[264] = 32'h0;
  assign config_rom[265] = 32'h0;
  assign config_rom[266] = 32'h2a;
  assign config_rom[267] = 32'h0;
  assign config_rom[268] = 32'h0;
  assign config_rom[269] = 32'h2a;
  assign config_rom[270] = 32'h0;
  assign config_rom[271] = 32'h0;
  assign config_rom[272] = 32'h2b;
  assign config_rom[273] = 32'h0;
  assign config_rom[274] = 32'h0;
  assign config_rom[275] = 32'h2b;
  assign config_rom[276] = 32'h0;
  assign config_rom[277] = 32'h0;
  assign config_rom[278] = 32'h2c;
  assign config_rom[279] = 32'h0;
  assign config_rom[280] = 32'h0;
  assign config_rom[281] = 32'h2c;
  assign config_rom[282] = 32'h0;
  assign config_rom[283] = 32'h0;
  assign config_rom[284] = 32'h2d;
  assign config_rom[285] = 32'h0;
  assign config_rom[286] = 32'h0;
  assign config_rom[287] = 32'h2d;
  assign config_rom[288] = 32'h0;
  assign config_rom[289] = 32'h0;
  assign config_rom[290] = 32'h2e;
  assign config_rom[291] = 32'h0;
  assign config_rom[292] = 32'h0;
  assign config_rom[293] = 32'h2e;
  assign config_rom[294] = 32'h0;
  assign config_rom[295] = 32'h0;
  assign config_rom[296] = 32'h2f;
  assign config_rom[297] = 32'h0;
  assign config_rom[298] = 32'h0;
  assign config_rom[299] = 32'h2f;
  assign config_rom[300] = 32'h0;
  assign config_rom[301] = 32'h0;
  assign config_rom[302] = 32'h30;
  assign config_rom[303] = 32'h0;
  assign config_rom[304] = 32'h0;
  assign config_rom[305] = 32'h30;
  assign config_rom[306] = 32'h0;
  assign config_rom[307] = 32'h0;
  assign config_rom[308] = 32'h31;
  assign config_rom[309] = 32'h0;
  assign config_rom[310] = 32'h0;
  assign config_rom[311] = 32'h31;
  assign config_rom[312] = 32'h0;
  assign config_rom[313] = 32'h0;
  assign config_rom[314] = 32'h32;
  assign config_rom[315] = 32'h0;
  assign config_rom[316] = 32'h0;
  assign config_rom[317] = 32'h32;
  assign config_rom[318] = 32'h0;
  assign config_rom[319] = 32'h0;
  assign config_rom[320] = 32'h33;
  assign config_rom[321] = 32'h0;
  assign config_rom[322] = 32'h0;
  assign config_rom[323] = 32'h33;
  assign config_rom[324] = 32'h0;
  assign config_rom[325] = 32'h0;
  assign config_rom[326] = 32'h34;
  assign config_rom[327] = 32'h0;
  assign config_rom[328] = 32'h0;
  assign config_rom[329] = 32'h34;
  assign config_rom[330] = 32'h0;
  assign config_rom[331] = 32'h0;
  assign config_rom[332] = 32'h35;
  assign config_rom[333] = 32'h0;
  assign config_rom[334] = 32'h0;
  assign config_rom[335] = 32'h35;
  assign config_rom[336] = 32'h0;
  assign config_rom[337] = 32'h0;
  assign config_rom[338] = 32'h36;
  assign config_rom[339] = 32'h0;
  assign config_rom[340] = 32'h0;
  assign config_rom[341] = 32'h36;
  assign config_rom[342] = 32'h0;
  assign config_rom[343] = 32'h0;
  assign config_rom[344] = 32'h37;
  assign config_rom[345] = 32'h0;
  assign config_rom[346] = 32'h0;
  assign config_rom[347] = 32'h37;
  assign config_rom[348] = 32'h0;
  assign config_rom[349] = 32'h0;
  assign config_rom[350] = 32'h38;
  assign config_rom[351] = 32'h0;
  assign config_rom[352] = 32'h0;
  assign config_rom[353] = 32'h38;
  assign config_rom[354] = 32'h0;
  assign config_rom[355] = 32'h0;
  assign config_rom[356] = 32'h39;
  assign config_rom[357] = 32'h0;
  assign config_rom[358] = 32'h0;
  assign config_rom[359] = 32'h39;
  assign config_rom[360] = 32'h0;
  assign config_rom[361] = 32'h0;
  assign config_rom[362] = 32'h3a;
  assign config_rom[363] = 32'h0;
  assign config_rom[364] = 32'h0;
  assign config_rom[365] = 32'h3a;
  assign config_rom[366] = 32'h0;
  assign config_rom[367] = 32'h0;
  assign config_rom[368] = 32'h3b;
  assign config_rom[369] = 32'h0;
  assign config_rom[370] = 32'h0;
  assign config_rom[371] = 32'h3b;
  assign config_rom[372] = 32'h0;
  assign config_rom[373] = 32'h0;
  assign config_rom[374] = 32'h3c;
  assign config_rom[375] = 32'h0;
  assign config_rom[376] = 32'h0;
  assign config_rom[377] = 32'h3c;
  assign config_rom[378] = 32'h0;
  assign config_rom[379] = 32'h0;
  assign config_rom[380] = 32'h3d;
  assign config_rom[381] = 32'h0;
  assign config_rom[382] = 32'h0;
  assign config_rom[383] = 32'h3d;
  assign config_rom[384] = 32'h0;
  assign config_rom[385] = 32'h0;
  assign config_rom[386] = 32'h3e;
  assign config_rom[387] = 32'h0;
  assign config_rom[388] = 32'h0;
  assign config_rom[389] = 32'h3e;
  assign config_rom[390] = 32'h0;
  assign config_rom[391] = 32'h0;
  assign config_rom[392] = 32'h3f;
  assign config_rom[393] = 32'h0;
  assign config_rom[394] = 32'h0;
  assign config_rom[395] = 32'h3f;
  assign config_rom[396] = 32'h0;
  assign config_rom[397] = 32'h0;
  assign config_rom[398] = 32'h40;
  assign config_rom[399] = 32'h0;
  assign config_rom[400] = 32'h0;
  assign config_rom[401] = 32'h40;
  assign config_rom[402] = 32'h0;
  assign config_rom[403] = 32'h0;
  assign config_rom[404] = 32'h41;
  assign config_rom[405] = 32'h0;
  assign config_rom[406] = 32'h0;
  assign config_rom[407] = 32'h41;
  assign config_rom[408] = 32'h0;
  assign config_rom[409] = 32'h0;
  assign config_rom[410] = 32'h42;
  assign config_rom[411] = 32'h0;
  assign config_rom[412] = 32'h0;
  assign config_rom[413] = 32'h42;
  assign config_rom[414] = 32'h0;
  assign config_rom[415] = 32'h0;
  assign config_rom[416] = 32'h43;
  assign config_rom[417] = 32'h0;
  assign config_rom[418] = 32'h0;
  assign config_rom[419] = 32'h43;
  assign config_rom[420] = 32'h0;
  assign config_rom[421] = 32'h0;
  assign config_rom[422] = 32'h44;
  assign config_rom[423] = 32'h0;
  assign config_rom[424] = 32'h0;
  assign config_rom[425] = 32'h44;
  assign config_rom[426] = 32'h0;
  assign config_rom[427] = 32'h0;
  assign config_rom[428] = 32'h45;
  assign config_rom[429] = 32'h0;
  assign config_rom[430] = 32'h0;
  assign config_rom[431] = 32'h45;
  assign config_rom[432] = 32'h0;
  assign config_rom[433] = 32'h0;
  assign config_rom[434] = 32'h46;
  assign config_rom[435] = 32'h0;
  assign config_rom[436] = 32'h0;
  assign config_rom[437] = 32'h46;
  assign config_rom[438] = 32'h0;
  assign config_rom[439] = 32'h0;
  assign config_rom[440] = 32'h47;
  assign config_rom[441] = 32'h0;
  assign config_rom[442] = 32'h0;
  assign config_rom[443] = 32'h47;
  assign config_rom[444] = 32'h0;
  assign config_rom[445] = 32'h0;
  assign config_rom[446] = 32'h48;
  assign config_rom[447] = 32'h0;
  assign config_rom[448] = 32'h0;
  assign config_rom[449] = 32'h48;
  assign config_rom[450] = 32'h0;
  assign config_rom[451] = 32'h0;
  assign config_rom[452] = 32'h49;
  assign config_rom[453] = 32'h0;
  assign config_rom[454] = 32'h0;
  assign config_rom[455] = 32'h49;
  assign config_rom[456] = 32'h0;
  assign config_rom[457] = 32'h0;
  assign config_rom[458] = 32'h4a;
  assign config_rom[459] = 32'h0;
  assign config_rom[460] = 32'h0;
  assign config_rom[461] = 32'h4a;
  assign config_rom[462] = 32'h0;
  assign config_rom[463] = 32'h0;
  assign config_rom[464] = 32'h4b;
  assign config_rom[465] = 32'h0;
  assign config_rom[466] = 32'h0;
  assign config_rom[467] = 32'h4b;
  assign config_rom[468] = 32'h0;
  assign config_rom[469] = 32'h0;
  assign config_rom[470] = 32'h4c;
  assign config_rom[471] = 32'h0;
  assign config_rom[472] = 32'h0;
  assign config_rom[473] = 32'h4c;
  assign config_rom[474] = 32'h0;
  assign config_rom[475] = 32'h0;
  assign config_rom[476] = 32'h4d;
  assign config_rom[477] = 32'h0;
  assign config_rom[478] = 32'h0;
  assign config_rom[479] = 32'h4d;
  assign config_rom[480] = 32'h0;
  assign config_rom[481] = 32'h0;
  assign config_rom[482] = 32'h4e;
  assign config_rom[483] = 32'h0;
  assign config_rom[484] = 32'h0;
  assign config_rom[485] = 32'h4e;
  assign config_rom[486] = 32'h0;
  assign config_rom[487] = 32'h0;
  assign config_rom[488] = 32'h4f;
  assign config_rom[489] = 32'h0;
  assign config_rom[490] = 32'h0;
  assign config_rom[491] = 32'h4f;
  assign config_rom[492] = 32'h0;
  assign config_rom[493] = 32'h0;
  //Config Rom configuration - End
  //Config Rom configuration regs and wires - End

  //Data Producer regs and wires - Begin
  reg [2-1:0] fsm_produce_data;
  localparam fsm_produce = 0;
  localparam fsm_done = 1;

  //Data Producer regs and wires - End

  //Data Producer - Begin

  always @(posedge clk) begin
    if(rst) begin
      start <= 0;
      config_counter <= 0;
      grn_aws_read_data_valid <= 0;
      grn_aws_done_rd_data <= 0;
      grn_aws_done_wr_data <= 0;
      fsm_produce_data <= fsm_produce;
    end else begin
      start <= 1;
      case(fsm_produce_data)
        fsm_produce: begin
          grn_aws_read_data_valid <= 1;
          grn_aws_read_data <= config_rom[config_counter];
          if(grn_aws_request_read && grn_aws_read_data_valid) begin
            config_counter <= config_counter + 1;
            grn_aws_read_data_valid <= 0;
          end 
          if(config_counter == 494) begin
            grn_aws_read_data_valid <= 0;
            fsm_produce_data <= fsm_done;
          end 
        end
        fsm_done: begin
          grn_aws_done_rd_data <= 1;
        end
      endcase
    end
  end

  //Data Producer - End

  //Data Consumer - Begin
  reg [71-1:0] max_data_counter;
  reg [4-1:0] rd_counter;
  reg [256-1:0] data;
  wire [32-1:0] period;
  wire [32-1:0] transient;
  wire [70-1:0] i_state;
  wire [70-1:0] s_state;
  assign period = data[31:0];
  assign transient = data[63:32];
  assign s_state = data[133:64];
  assign i_state = data[229:160];
  reg [2-1:0] fsm_consume_data;
  localparam fsm_consume_data_rd = 0;
  localparam fsm_consume_data_show = 1;
  localparam fsm_consume_data_done = 2;

  always @(posedge clk) begin
    if(rst) begin
      rd_counter <= 0;
      max_data_counter <= 0;
      grn_aws_available_write <= 0;
      grn_aws_done_wr_data <= 0;
      fsm_consume_data <= fsm_consume_data_rd;
    end else begin
      case(fsm_consume_data)
        fsm_consume_data_rd: begin
          grn_aws_available_write <= 1;
          if(grn_aws_request_write) begin
            rd_counter <= rd_counter + 1;
            data <= { grn_aws_write_data, data[255:32] };
            if(rd_counter == 7) begin
              grn_aws_available_write <= 0;
              rd_counter <= 0;
              fsm_consume_data <= fsm_consume_data_show;
            end 
          end 
        end
        fsm_consume_data_show: begin
          if(max_data_counter == 79) begin
            fsm_consume_data <= fsm_consume_data_done;
          end else begin
            fsm_consume_data <= fsm_consume_data_rd;
          end
          $display("i_s: %h s_s: %h t: %h p: %h", i_state, s_state, transient, period);
          max_data_counter <= max_data_counter + 1;
        end
        fsm_consume_data_done: begin
          grn_aws_done_wr_data <= 1;
        end
      endcase
    end
  end

  //Data Consumer - Begin

  grn_aws_80
  grn_aws_80
  (
    .clk(clk),
    .rst(rst),
    .start(start),
    .grn_aws_done_rd_data(grn_aws_done_rd_data),
    .grn_aws_done_wr_data(grn_aws_done_wr_data),
    .grn_aws_request_read(grn_aws_request_read),
    .grn_aws_read_data_valid(grn_aws_read_data_valid),
    .grn_aws_read_data(grn_aws_read_data),
    .grn_aws_available_write(grn_aws_available_write),
    .grn_aws_request_write(grn_aws_request_write),
    .grn_aws_write_data(grn_aws_write_data),
    .grn_aws_done(grn_aws_done)
  );


  initial begin
    clk = 0;
    rst = 1;
    start = 0;
    grn_aws_done_rd_data = 0;
    grn_aws_done_wr_data = 0;
    grn_aws_read_data_valid = 0;
    grn_aws_read_data = 0;
    grn_aws_available_write = 0;
    config_counter = 0;
    fsm_produce_data = 0;
    max_data_counter = 0;
    rd_counter = 0;
    data = 0;
    fsm_consume_data = 0;
  end


  initial begin
    $dumpfile("uut.vcd");
    $dumpvars(0);
  end


  initial begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 0;
    #1000000;
    $finish;
  end

  always #5clk=~clk;

  always @(posedge clk) begin
    if(grn_aws_done) begin
      $display("ACC DONE!");
      $finish;
    end 
  end


  //Simulation sector - End

endmodule



module grn_aws_80
(
  input clk,
  input rst,
  input start,
  input grn_aws_done_rd_data,
  input grn_aws_done_wr_data,
  output reg grn_aws_request_read,
  input grn_aws_read_data_valid,
  input [32-1:0] grn_aws_read_data,
  input grn_aws_available_write,
  output reg grn_aws_request_write,
  output reg [32-1:0] grn_aws_write_data,
  output grn_aws_done
);

  assign grn_aws_done = &{ grn_aws_done_wr_data, grn_aws_done_rd_data };

  // grn pe instantiation regs and wires - Begin
  wire [80-1:0] grn_pe_config_output_done;
  wire [80-1:0] grn_pe_config_output_valid;
  wire [32-1:0] grn_pe_config_output [0:80-1];
  wire [80-1:0] grn_pe_output_read_enable;
  wire [80-1:0] grn_pe_output_valid;
  wire [32-1:0] grn_pe_output_data [0:80-1];
  wire [80-1:0] grn_pe_output_available;
  // grn pe instantiation regs and wires - end

  //Config wires and regs - Begin
  localparam [2-1:0] fsm_sd_idle = 0;
  localparam [2-1:0] fsm_sd_send_data = 1;
  localparam [2-1:0] fsm_sd_done = 2;
  reg [2-1:0] fms_cs;
  reg config_valid;
  reg [32-1:0] config_data;
  reg config_done;
  reg flag;
  //Config wires and regs - End

  //Data Reading - Begin

  always @(posedge clk) begin
    if(rst) begin
      grn_aws_request_read <= 0;
      config_valid <= 0;
      fms_cs <= fsm_sd_idle;
      config_done <= 0;
      flag <= 0;
    end else begin
      if(start) begin
        config_valid <= 0;
        grn_aws_request_read <= 0;
        flag <= 0;
        case(fms_cs)
          fsm_sd_idle: begin
            if(grn_aws_read_data_valid) begin
              grn_aws_request_read <= 1;
              flag <= 1;
              fms_cs <= fsm_sd_send_data;
            end else if(grn_aws_done_rd_data) begin
              fms_cs <= fsm_sd_done;
            end 
          end
          fsm_sd_send_data: begin
            if(grn_aws_read_data_valid | flag) begin
              config_data <= grn_aws_read_data;
              config_valid <= 1;
              grn_aws_request_read <= 1;
            end else if(grn_aws_done_rd_data) begin
              fms_cs <= fsm_sd_done;
            end else begin
              fms_cs <= fsm_sd_idle;
            end
          end
          fsm_sd_done: begin
            config_done <= 1;
          end
        endcase
      end 
    end
  end

  //Data Reading - End

  //Data Consumer - Begin
  reg consume_rd_enable;
  wire consume_rd_available;
  wire consume_rd_valid;
  wire [32-1:0] consume_rd_data;
  reg [2-1:0] fsm_consume_data;
  localparam fsm_consume_data_rq_rd = 0;
  localparam fsm_consume_data_rd = 1;
  localparam fsm_consume_data_wr = 2;

  always @(posedge clk) begin
    if(rst) begin
      consume_rd_enable <= 0;
      grn_aws_request_write <= 0;
      fsm_consume_data <= fsm_consume_data_rq_rd;
    end else begin
      consume_rd_enable <= 0;
      grn_aws_request_write <= 0;
      case(fsm_consume_data)
        fsm_consume_data_rq_rd: begin
          if(consume_rd_available) begin
            consume_rd_enable <= 1;
            fsm_consume_data <= fsm_consume_data_rd;
          end 
        end
        fsm_consume_data_rd: begin
          if(consume_rd_valid) begin
            grn_aws_write_data <= consume_rd_data;
            fsm_consume_data <= fsm_consume_data_wr;
          end 
        end
        fsm_consume_data_wr: begin
          if(grn_aws_available_write) begin
            grn_aws_request_write <= 1;
            fsm_consume_data <= fsm_consume_data_rq_rd;
          end 
        end
      endcase
    end
  end

  //Data Consumer - Begin

  //Assigns to the last PE
  assign grn_pe_output_valid[79] = 0;
  assign grn_pe_output_data[79] = 0;
  assign grn_pe_output_available[79] = 0;

  //PE modules instantiation - Begin

  grn_mem_pe
  grn_mem_pe_0
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(config_done),
    .config_input_valid(config_valid),
    .config_input(config_data),
    .config_output_done(grn_pe_config_output_done[0]),
    .config_output_valid(grn_pe_config_output_valid[0]),
    .config_output(grn_pe_config_output[0]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[0]),
    .pe_bypass_valid(grn_pe_output_valid[0]),
    .pe_bypass_data(grn_pe_output_data[0]),
    .pe_bypass_available(grn_pe_output_available[0]),
    .pe_output_read_enable(consume_rd_enable),
    .pe_output_valid(consume_rd_valid),
    .pe_output_data(consume_rd_data),
    .pe_output_available(consume_rd_available)
  );


  grn_mem_pe
  grn_mem_pe_1
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[0]),
    .config_input_valid(grn_pe_config_output_valid[0]),
    .config_input(grn_pe_config_output[0]),
    .config_output_done(grn_pe_config_output_done[1]),
    .config_output_valid(grn_pe_config_output_valid[1]),
    .config_output(grn_pe_config_output[1]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[1]),
    .pe_bypass_valid(grn_pe_output_valid[1]),
    .pe_bypass_data(grn_pe_output_data[1]),
    .pe_bypass_available(grn_pe_output_available[1]),
    .pe_output_read_enable(grn_pe_output_read_enable[0]),
    .pe_output_valid(grn_pe_output_valid[0]),
    .pe_output_data(grn_pe_output_data[0]),
    .pe_output_available(grn_pe_output_available[0])
  );


  grn_mem_pe
  grn_mem_pe_2
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[1]),
    .config_input_valid(grn_pe_config_output_valid[1]),
    .config_input(grn_pe_config_output[1]),
    .config_output_done(grn_pe_config_output_done[2]),
    .config_output_valid(grn_pe_config_output_valid[2]),
    .config_output(grn_pe_config_output[2]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[2]),
    .pe_bypass_valid(grn_pe_output_valid[2]),
    .pe_bypass_data(grn_pe_output_data[2]),
    .pe_bypass_available(grn_pe_output_available[2]),
    .pe_output_read_enable(grn_pe_output_read_enable[1]),
    .pe_output_valid(grn_pe_output_valid[1]),
    .pe_output_data(grn_pe_output_data[1]),
    .pe_output_available(grn_pe_output_available[1])
  );


  grn_mem_pe
  grn_mem_pe_3
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[2]),
    .config_input_valid(grn_pe_config_output_valid[2]),
    .config_input(grn_pe_config_output[2]),
    .config_output_done(grn_pe_config_output_done[3]),
    .config_output_valid(grn_pe_config_output_valid[3]),
    .config_output(grn_pe_config_output[3]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[3]),
    .pe_bypass_valid(grn_pe_output_valid[3]),
    .pe_bypass_data(grn_pe_output_data[3]),
    .pe_bypass_available(grn_pe_output_available[3]),
    .pe_output_read_enable(grn_pe_output_read_enable[2]),
    .pe_output_valid(grn_pe_output_valid[2]),
    .pe_output_data(grn_pe_output_data[2]),
    .pe_output_available(grn_pe_output_available[2])
  );


  grn_mem_pe
  grn_mem_pe_4
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[3]),
    .config_input_valid(grn_pe_config_output_valid[3]),
    .config_input(grn_pe_config_output[3]),
    .config_output_done(grn_pe_config_output_done[4]),
    .config_output_valid(grn_pe_config_output_valid[4]),
    .config_output(grn_pe_config_output[4]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[4]),
    .pe_bypass_valid(grn_pe_output_valid[4]),
    .pe_bypass_data(grn_pe_output_data[4]),
    .pe_bypass_available(grn_pe_output_available[4]),
    .pe_output_read_enable(grn_pe_output_read_enable[3]),
    .pe_output_valid(grn_pe_output_valid[3]),
    .pe_output_data(grn_pe_output_data[3]),
    .pe_output_available(grn_pe_output_available[3])
  );


  grn_mem_pe
  grn_mem_pe_5
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[4]),
    .config_input_valid(grn_pe_config_output_valid[4]),
    .config_input(grn_pe_config_output[4]),
    .config_output_done(grn_pe_config_output_done[5]),
    .config_output_valid(grn_pe_config_output_valid[5]),
    .config_output(grn_pe_config_output[5]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[5]),
    .pe_bypass_valid(grn_pe_output_valid[5]),
    .pe_bypass_data(grn_pe_output_data[5]),
    .pe_bypass_available(grn_pe_output_available[5]),
    .pe_output_read_enable(grn_pe_output_read_enable[4]),
    .pe_output_valid(grn_pe_output_valid[4]),
    .pe_output_data(grn_pe_output_data[4]),
    .pe_output_available(grn_pe_output_available[4])
  );


  grn_mem_pe
  grn_mem_pe_6
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[5]),
    .config_input_valid(grn_pe_config_output_valid[5]),
    .config_input(grn_pe_config_output[5]),
    .config_output_done(grn_pe_config_output_done[6]),
    .config_output_valid(grn_pe_config_output_valid[6]),
    .config_output(grn_pe_config_output[6]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[6]),
    .pe_bypass_valid(grn_pe_output_valid[6]),
    .pe_bypass_data(grn_pe_output_data[6]),
    .pe_bypass_available(grn_pe_output_available[6]),
    .pe_output_read_enable(grn_pe_output_read_enable[5]),
    .pe_output_valid(grn_pe_output_valid[5]),
    .pe_output_data(grn_pe_output_data[5]),
    .pe_output_available(grn_pe_output_available[5])
  );


  grn_mem_pe
  grn_mem_pe_7
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[6]),
    .config_input_valid(grn_pe_config_output_valid[6]),
    .config_input(grn_pe_config_output[6]),
    .config_output_done(grn_pe_config_output_done[7]),
    .config_output_valid(grn_pe_config_output_valid[7]),
    .config_output(grn_pe_config_output[7]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[7]),
    .pe_bypass_valid(grn_pe_output_valid[7]),
    .pe_bypass_data(grn_pe_output_data[7]),
    .pe_bypass_available(grn_pe_output_available[7]),
    .pe_output_read_enable(grn_pe_output_read_enable[6]),
    .pe_output_valid(grn_pe_output_valid[6]),
    .pe_output_data(grn_pe_output_data[6]),
    .pe_output_available(grn_pe_output_available[6])
  );


  grn_mem_pe
  grn_mem_pe_8
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[7]),
    .config_input_valid(grn_pe_config_output_valid[7]),
    .config_input(grn_pe_config_output[7]),
    .config_output_done(grn_pe_config_output_done[8]),
    .config_output_valid(grn_pe_config_output_valid[8]),
    .config_output(grn_pe_config_output[8]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[8]),
    .pe_bypass_valid(grn_pe_output_valid[8]),
    .pe_bypass_data(grn_pe_output_data[8]),
    .pe_bypass_available(grn_pe_output_available[8]),
    .pe_output_read_enable(grn_pe_output_read_enable[7]),
    .pe_output_valid(grn_pe_output_valid[7]),
    .pe_output_data(grn_pe_output_data[7]),
    .pe_output_available(grn_pe_output_available[7])
  );


  grn_mem_pe
  grn_mem_pe_9
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[8]),
    .config_input_valid(grn_pe_config_output_valid[8]),
    .config_input(grn_pe_config_output[8]),
    .config_output_done(grn_pe_config_output_done[9]),
    .config_output_valid(grn_pe_config_output_valid[9]),
    .config_output(grn_pe_config_output[9]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[9]),
    .pe_bypass_valid(grn_pe_output_valid[9]),
    .pe_bypass_data(grn_pe_output_data[9]),
    .pe_bypass_available(grn_pe_output_available[9]),
    .pe_output_read_enable(grn_pe_output_read_enable[8]),
    .pe_output_valid(grn_pe_output_valid[8]),
    .pe_output_data(grn_pe_output_data[8]),
    .pe_output_available(grn_pe_output_available[8])
  );


  grn_mem_pe
  grn_mem_pe_10
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[9]),
    .config_input_valid(grn_pe_config_output_valid[9]),
    .config_input(grn_pe_config_output[9]),
    .config_output_done(grn_pe_config_output_done[10]),
    .config_output_valid(grn_pe_config_output_valid[10]),
    .config_output(grn_pe_config_output[10]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[10]),
    .pe_bypass_valid(grn_pe_output_valid[10]),
    .pe_bypass_data(grn_pe_output_data[10]),
    .pe_bypass_available(grn_pe_output_available[10]),
    .pe_output_read_enable(grn_pe_output_read_enable[9]),
    .pe_output_valid(grn_pe_output_valid[9]),
    .pe_output_data(grn_pe_output_data[9]),
    .pe_output_available(grn_pe_output_available[9])
  );


  grn_mem_pe
  grn_mem_pe_11
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[10]),
    .config_input_valid(grn_pe_config_output_valid[10]),
    .config_input(grn_pe_config_output[10]),
    .config_output_done(grn_pe_config_output_done[11]),
    .config_output_valid(grn_pe_config_output_valid[11]),
    .config_output(grn_pe_config_output[11]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[11]),
    .pe_bypass_valid(grn_pe_output_valid[11]),
    .pe_bypass_data(grn_pe_output_data[11]),
    .pe_bypass_available(grn_pe_output_available[11]),
    .pe_output_read_enable(grn_pe_output_read_enable[10]),
    .pe_output_valid(grn_pe_output_valid[10]),
    .pe_output_data(grn_pe_output_data[10]),
    .pe_output_available(grn_pe_output_available[10])
  );


  grn_mem_pe
  grn_mem_pe_12
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[11]),
    .config_input_valid(grn_pe_config_output_valid[11]),
    .config_input(grn_pe_config_output[11]),
    .config_output_done(grn_pe_config_output_done[12]),
    .config_output_valid(grn_pe_config_output_valid[12]),
    .config_output(grn_pe_config_output[12]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[12]),
    .pe_bypass_valid(grn_pe_output_valid[12]),
    .pe_bypass_data(grn_pe_output_data[12]),
    .pe_bypass_available(grn_pe_output_available[12]),
    .pe_output_read_enable(grn_pe_output_read_enable[11]),
    .pe_output_valid(grn_pe_output_valid[11]),
    .pe_output_data(grn_pe_output_data[11]),
    .pe_output_available(grn_pe_output_available[11])
  );


  grn_mem_pe
  grn_mem_pe_13
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[12]),
    .config_input_valid(grn_pe_config_output_valid[12]),
    .config_input(grn_pe_config_output[12]),
    .config_output_done(grn_pe_config_output_done[13]),
    .config_output_valid(grn_pe_config_output_valid[13]),
    .config_output(grn_pe_config_output[13]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[13]),
    .pe_bypass_valid(grn_pe_output_valid[13]),
    .pe_bypass_data(grn_pe_output_data[13]),
    .pe_bypass_available(grn_pe_output_available[13]),
    .pe_output_read_enable(grn_pe_output_read_enable[12]),
    .pe_output_valid(grn_pe_output_valid[12]),
    .pe_output_data(grn_pe_output_data[12]),
    .pe_output_available(grn_pe_output_available[12])
  );


  grn_mem_pe
  grn_mem_pe_14
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[13]),
    .config_input_valid(grn_pe_config_output_valid[13]),
    .config_input(grn_pe_config_output[13]),
    .config_output_done(grn_pe_config_output_done[14]),
    .config_output_valid(grn_pe_config_output_valid[14]),
    .config_output(grn_pe_config_output[14]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[14]),
    .pe_bypass_valid(grn_pe_output_valid[14]),
    .pe_bypass_data(grn_pe_output_data[14]),
    .pe_bypass_available(grn_pe_output_available[14]),
    .pe_output_read_enable(grn_pe_output_read_enable[13]),
    .pe_output_valid(grn_pe_output_valid[13]),
    .pe_output_data(grn_pe_output_data[13]),
    .pe_output_available(grn_pe_output_available[13])
  );


  grn_mem_pe
  grn_mem_pe_15
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[14]),
    .config_input_valid(grn_pe_config_output_valid[14]),
    .config_input(grn_pe_config_output[14]),
    .config_output_done(grn_pe_config_output_done[15]),
    .config_output_valid(grn_pe_config_output_valid[15]),
    .config_output(grn_pe_config_output[15]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[15]),
    .pe_bypass_valid(grn_pe_output_valid[15]),
    .pe_bypass_data(grn_pe_output_data[15]),
    .pe_bypass_available(grn_pe_output_available[15]),
    .pe_output_read_enable(grn_pe_output_read_enable[14]),
    .pe_output_valid(grn_pe_output_valid[14]),
    .pe_output_data(grn_pe_output_data[14]),
    .pe_output_available(grn_pe_output_available[14])
  );


  grn_mem_pe
  grn_mem_pe_16
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[15]),
    .config_input_valid(grn_pe_config_output_valid[15]),
    .config_input(grn_pe_config_output[15]),
    .config_output_done(grn_pe_config_output_done[16]),
    .config_output_valid(grn_pe_config_output_valid[16]),
    .config_output(grn_pe_config_output[16]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[16]),
    .pe_bypass_valid(grn_pe_output_valid[16]),
    .pe_bypass_data(grn_pe_output_data[16]),
    .pe_bypass_available(grn_pe_output_available[16]),
    .pe_output_read_enable(grn_pe_output_read_enable[15]),
    .pe_output_valid(grn_pe_output_valid[15]),
    .pe_output_data(grn_pe_output_data[15]),
    .pe_output_available(grn_pe_output_available[15])
  );


  grn_mem_pe
  grn_mem_pe_17
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[16]),
    .config_input_valid(grn_pe_config_output_valid[16]),
    .config_input(grn_pe_config_output[16]),
    .config_output_done(grn_pe_config_output_done[17]),
    .config_output_valid(grn_pe_config_output_valid[17]),
    .config_output(grn_pe_config_output[17]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[17]),
    .pe_bypass_valid(grn_pe_output_valid[17]),
    .pe_bypass_data(grn_pe_output_data[17]),
    .pe_bypass_available(grn_pe_output_available[17]),
    .pe_output_read_enable(grn_pe_output_read_enable[16]),
    .pe_output_valid(grn_pe_output_valid[16]),
    .pe_output_data(grn_pe_output_data[16]),
    .pe_output_available(grn_pe_output_available[16])
  );


  grn_mem_pe
  grn_mem_pe_18
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[17]),
    .config_input_valid(grn_pe_config_output_valid[17]),
    .config_input(grn_pe_config_output[17]),
    .config_output_done(grn_pe_config_output_done[18]),
    .config_output_valid(grn_pe_config_output_valid[18]),
    .config_output(grn_pe_config_output[18]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[18]),
    .pe_bypass_valid(grn_pe_output_valid[18]),
    .pe_bypass_data(grn_pe_output_data[18]),
    .pe_bypass_available(grn_pe_output_available[18]),
    .pe_output_read_enable(grn_pe_output_read_enable[17]),
    .pe_output_valid(grn_pe_output_valid[17]),
    .pe_output_data(grn_pe_output_data[17]),
    .pe_output_available(grn_pe_output_available[17])
  );


  grn_mem_pe
  grn_mem_pe_19
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[18]),
    .config_input_valid(grn_pe_config_output_valid[18]),
    .config_input(grn_pe_config_output[18]),
    .config_output_done(grn_pe_config_output_done[19]),
    .config_output_valid(grn_pe_config_output_valid[19]),
    .config_output(grn_pe_config_output[19]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[19]),
    .pe_bypass_valid(grn_pe_output_valid[19]),
    .pe_bypass_data(grn_pe_output_data[19]),
    .pe_bypass_available(grn_pe_output_available[19]),
    .pe_output_read_enable(grn_pe_output_read_enable[18]),
    .pe_output_valid(grn_pe_output_valid[18]),
    .pe_output_data(grn_pe_output_data[18]),
    .pe_output_available(grn_pe_output_available[18])
  );


  grn_mem_pe
  grn_mem_pe_20
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[19]),
    .config_input_valid(grn_pe_config_output_valid[19]),
    .config_input(grn_pe_config_output[19]),
    .config_output_done(grn_pe_config_output_done[20]),
    .config_output_valid(grn_pe_config_output_valid[20]),
    .config_output(grn_pe_config_output[20]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[20]),
    .pe_bypass_valid(grn_pe_output_valid[20]),
    .pe_bypass_data(grn_pe_output_data[20]),
    .pe_bypass_available(grn_pe_output_available[20]),
    .pe_output_read_enable(grn_pe_output_read_enable[19]),
    .pe_output_valid(grn_pe_output_valid[19]),
    .pe_output_data(grn_pe_output_data[19]),
    .pe_output_available(grn_pe_output_available[19])
  );


  grn_mem_pe
  grn_mem_pe_21
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[20]),
    .config_input_valid(grn_pe_config_output_valid[20]),
    .config_input(grn_pe_config_output[20]),
    .config_output_done(grn_pe_config_output_done[21]),
    .config_output_valid(grn_pe_config_output_valid[21]),
    .config_output(grn_pe_config_output[21]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[21]),
    .pe_bypass_valid(grn_pe_output_valid[21]),
    .pe_bypass_data(grn_pe_output_data[21]),
    .pe_bypass_available(grn_pe_output_available[21]),
    .pe_output_read_enable(grn_pe_output_read_enable[20]),
    .pe_output_valid(grn_pe_output_valid[20]),
    .pe_output_data(grn_pe_output_data[20]),
    .pe_output_available(grn_pe_output_available[20])
  );


  grn_mem_pe
  grn_mem_pe_22
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[21]),
    .config_input_valid(grn_pe_config_output_valid[21]),
    .config_input(grn_pe_config_output[21]),
    .config_output_done(grn_pe_config_output_done[22]),
    .config_output_valid(grn_pe_config_output_valid[22]),
    .config_output(grn_pe_config_output[22]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[22]),
    .pe_bypass_valid(grn_pe_output_valid[22]),
    .pe_bypass_data(grn_pe_output_data[22]),
    .pe_bypass_available(grn_pe_output_available[22]),
    .pe_output_read_enable(grn_pe_output_read_enable[21]),
    .pe_output_valid(grn_pe_output_valid[21]),
    .pe_output_data(grn_pe_output_data[21]),
    .pe_output_available(grn_pe_output_available[21])
  );


  grn_mem_pe
  grn_mem_pe_23
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[22]),
    .config_input_valid(grn_pe_config_output_valid[22]),
    .config_input(grn_pe_config_output[22]),
    .config_output_done(grn_pe_config_output_done[23]),
    .config_output_valid(grn_pe_config_output_valid[23]),
    .config_output(grn_pe_config_output[23]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[23]),
    .pe_bypass_valid(grn_pe_output_valid[23]),
    .pe_bypass_data(grn_pe_output_data[23]),
    .pe_bypass_available(grn_pe_output_available[23]),
    .pe_output_read_enable(grn_pe_output_read_enable[22]),
    .pe_output_valid(grn_pe_output_valid[22]),
    .pe_output_data(grn_pe_output_data[22]),
    .pe_output_available(grn_pe_output_available[22])
  );


  grn_mem_pe
  grn_mem_pe_24
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[23]),
    .config_input_valid(grn_pe_config_output_valid[23]),
    .config_input(grn_pe_config_output[23]),
    .config_output_done(grn_pe_config_output_done[24]),
    .config_output_valid(grn_pe_config_output_valid[24]),
    .config_output(grn_pe_config_output[24]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[24]),
    .pe_bypass_valid(grn_pe_output_valid[24]),
    .pe_bypass_data(grn_pe_output_data[24]),
    .pe_bypass_available(grn_pe_output_available[24]),
    .pe_output_read_enable(grn_pe_output_read_enable[23]),
    .pe_output_valid(grn_pe_output_valid[23]),
    .pe_output_data(grn_pe_output_data[23]),
    .pe_output_available(grn_pe_output_available[23])
  );


  grn_mem_pe
  grn_mem_pe_25
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[24]),
    .config_input_valid(grn_pe_config_output_valid[24]),
    .config_input(grn_pe_config_output[24]),
    .config_output_done(grn_pe_config_output_done[25]),
    .config_output_valid(grn_pe_config_output_valid[25]),
    .config_output(grn_pe_config_output[25]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[25]),
    .pe_bypass_valid(grn_pe_output_valid[25]),
    .pe_bypass_data(grn_pe_output_data[25]),
    .pe_bypass_available(grn_pe_output_available[25]),
    .pe_output_read_enable(grn_pe_output_read_enable[24]),
    .pe_output_valid(grn_pe_output_valid[24]),
    .pe_output_data(grn_pe_output_data[24]),
    .pe_output_available(grn_pe_output_available[24])
  );


  grn_mem_pe
  grn_mem_pe_26
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[25]),
    .config_input_valid(grn_pe_config_output_valid[25]),
    .config_input(grn_pe_config_output[25]),
    .config_output_done(grn_pe_config_output_done[26]),
    .config_output_valid(grn_pe_config_output_valid[26]),
    .config_output(grn_pe_config_output[26]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[26]),
    .pe_bypass_valid(grn_pe_output_valid[26]),
    .pe_bypass_data(grn_pe_output_data[26]),
    .pe_bypass_available(grn_pe_output_available[26]),
    .pe_output_read_enable(grn_pe_output_read_enable[25]),
    .pe_output_valid(grn_pe_output_valid[25]),
    .pe_output_data(grn_pe_output_data[25]),
    .pe_output_available(grn_pe_output_available[25])
  );


  grn_mem_pe
  grn_mem_pe_27
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[26]),
    .config_input_valid(grn_pe_config_output_valid[26]),
    .config_input(grn_pe_config_output[26]),
    .config_output_done(grn_pe_config_output_done[27]),
    .config_output_valid(grn_pe_config_output_valid[27]),
    .config_output(grn_pe_config_output[27]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[27]),
    .pe_bypass_valid(grn_pe_output_valid[27]),
    .pe_bypass_data(grn_pe_output_data[27]),
    .pe_bypass_available(grn_pe_output_available[27]),
    .pe_output_read_enable(grn_pe_output_read_enable[26]),
    .pe_output_valid(grn_pe_output_valid[26]),
    .pe_output_data(grn_pe_output_data[26]),
    .pe_output_available(grn_pe_output_available[26])
  );


  grn_mem_pe
  grn_mem_pe_28
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[27]),
    .config_input_valid(grn_pe_config_output_valid[27]),
    .config_input(grn_pe_config_output[27]),
    .config_output_done(grn_pe_config_output_done[28]),
    .config_output_valid(grn_pe_config_output_valid[28]),
    .config_output(grn_pe_config_output[28]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[28]),
    .pe_bypass_valid(grn_pe_output_valid[28]),
    .pe_bypass_data(grn_pe_output_data[28]),
    .pe_bypass_available(grn_pe_output_available[28]),
    .pe_output_read_enable(grn_pe_output_read_enable[27]),
    .pe_output_valid(grn_pe_output_valid[27]),
    .pe_output_data(grn_pe_output_data[27]),
    .pe_output_available(grn_pe_output_available[27])
  );


  grn_mem_pe
  grn_mem_pe_29
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[28]),
    .config_input_valid(grn_pe_config_output_valid[28]),
    .config_input(grn_pe_config_output[28]),
    .config_output_done(grn_pe_config_output_done[29]),
    .config_output_valid(grn_pe_config_output_valid[29]),
    .config_output(grn_pe_config_output[29]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[29]),
    .pe_bypass_valid(grn_pe_output_valid[29]),
    .pe_bypass_data(grn_pe_output_data[29]),
    .pe_bypass_available(grn_pe_output_available[29]),
    .pe_output_read_enable(grn_pe_output_read_enable[28]),
    .pe_output_valid(grn_pe_output_valid[28]),
    .pe_output_data(grn_pe_output_data[28]),
    .pe_output_available(grn_pe_output_available[28])
  );


  grn_mem_pe
  grn_mem_pe_30
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[29]),
    .config_input_valid(grn_pe_config_output_valid[29]),
    .config_input(grn_pe_config_output[29]),
    .config_output_done(grn_pe_config_output_done[30]),
    .config_output_valid(grn_pe_config_output_valid[30]),
    .config_output(grn_pe_config_output[30]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[30]),
    .pe_bypass_valid(grn_pe_output_valid[30]),
    .pe_bypass_data(grn_pe_output_data[30]),
    .pe_bypass_available(grn_pe_output_available[30]),
    .pe_output_read_enable(grn_pe_output_read_enable[29]),
    .pe_output_valid(grn_pe_output_valid[29]),
    .pe_output_data(grn_pe_output_data[29]),
    .pe_output_available(grn_pe_output_available[29])
  );


  grn_mem_pe
  grn_mem_pe_31
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[30]),
    .config_input_valid(grn_pe_config_output_valid[30]),
    .config_input(grn_pe_config_output[30]),
    .config_output_done(grn_pe_config_output_done[31]),
    .config_output_valid(grn_pe_config_output_valid[31]),
    .config_output(grn_pe_config_output[31]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[31]),
    .pe_bypass_valid(grn_pe_output_valid[31]),
    .pe_bypass_data(grn_pe_output_data[31]),
    .pe_bypass_available(grn_pe_output_available[31]),
    .pe_output_read_enable(grn_pe_output_read_enable[30]),
    .pe_output_valid(grn_pe_output_valid[30]),
    .pe_output_data(grn_pe_output_data[30]),
    .pe_output_available(grn_pe_output_available[30])
  );


  grn_mem_pe
  grn_mem_pe_32
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[31]),
    .config_input_valid(grn_pe_config_output_valid[31]),
    .config_input(grn_pe_config_output[31]),
    .config_output_done(grn_pe_config_output_done[32]),
    .config_output_valid(grn_pe_config_output_valid[32]),
    .config_output(grn_pe_config_output[32]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[32]),
    .pe_bypass_valid(grn_pe_output_valid[32]),
    .pe_bypass_data(grn_pe_output_data[32]),
    .pe_bypass_available(grn_pe_output_available[32]),
    .pe_output_read_enable(grn_pe_output_read_enable[31]),
    .pe_output_valid(grn_pe_output_valid[31]),
    .pe_output_data(grn_pe_output_data[31]),
    .pe_output_available(grn_pe_output_available[31])
  );


  grn_mem_pe
  grn_mem_pe_33
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[32]),
    .config_input_valid(grn_pe_config_output_valid[32]),
    .config_input(grn_pe_config_output[32]),
    .config_output_done(grn_pe_config_output_done[33]),
    .config_output_valid(grn_pe_config_output_valid[33]),
    .config_output(grn_pe_config_output[33]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[33]),
    .pe_bypass_valid(grn_pe_output_valid[33]),
    .pe_bypass_data(grn_pe_output_data[33]),
    .pe_bypass_available(grn_pe_output_available[33]),
    .pe_output_read_enable(grn_pe_output_read_enable[32]),
    .pe_output_valid(grn_pe_output_valid[32]),
    .pe_output_data(grn_pe_output_data[32]),
    .pe_output_available(grn_pe_output_available[32])
  );


  grn_mem_pe
  grn_mem_pe_34
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[33]),
    .config_input_valid(grn_pe_config_output_valid[33]),
    .config_input(grn_pe_config_output[33]),
    .config_output_done(grn_pe_config_output_done[34]),
    .config_output_valid(grn_pe_config_output_valid[34]),
    .config_output(grn_pe_config_output[34]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[34]),
    .pe_bypass_valid(grn_pe_output_valid[34]),
    .pe_bypass_data(grn_pe_output_data[34]),
    .pe_bypass_available(grn_pe_output_available[34]),
    .pe_output_read_enable(grn_pe_output_read_enable[33]),
    .pe_output_valid(grn_pe_output_valid[33]),
    .pe_output_data(grn_pe_output_data[33]),
    .pe_output_available(grn_pe_output_available[33])
  );


  grn_mem_pe
  grn_mem_pe_35
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[34]),
    .config_input_valid(grn_pe_config_output_valid[34]),
    .config_input(grn_pe_config_output[34]),
    .config_output_done(grn_pe_config_output_done[35]),
    .config_output_valid(grn_pe_config_output_valid[35]),
    .config_output(grn_pe_config_output[35]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[35]),
    .pe_bypass_valid(grn_pe_output_valid[35]),
    .pe_bypass_data(grn_pe_output_data[35]),
    .pe_bypass_available(grn_pe_output_available[35]),
    .pe_output_read_enable(grn_pe_output_read_enable[34]),
    .pe_output_valid(grn_pe_output_valid[34]),
    .pe_output_data(grn_pe_output_data[34]),
    .pe_output_available(grn_pe_output_available[34])
  );


  grn_mem_pe
  grn_mem_pe_36
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[35]),
    .config_input_valid(grn_pe_config_output_valid[35]),
    .config_input(grn_pe_config_output[35]),
    .config_output_done(grn_pe_config_output_done[36]),
    .config_output_valid(grn_pe_config_output_valid[36]),
    .config_output(grn_pe_config_output[36]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[36]),
    .pe_bypass_valid(grn_pe_output_valid[36]),
    .pe_bypass_data(grn_pe_output_data[36]),
    .pe_bypass_available(grn_pe_output_available[36]),
    .pe_output_read_enable(grn_pe_output_read_enable[35]),
    .pe_output_valid(grn_pe_output_valid[35]),
    .pe_output_data(grn_pe_output_data[35]),
    .pe_output_available(grn_pe_output_available[35])
  );


  grn_mem_pe
  grn_mem_pe_37
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[36]),
    .config_input_valid(grn_pe_config_output_valid[36]),
    .config_input(grn_pe_config_output[36]),
    .config_output_done(grn_pe_config_output_done[37]),
    .config_output_valid(grn_pe_config_output_valid[37]),
    .config_output(grn_pe_config_output[37]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[37]),
    .pe_bypass_valid(grn_pe_output_valid[37]),
    .pe_bypass_data(grn_pe_output_data[37]),
    .pe_bypass_available(grn_pe_output_available[37]),
    .pe_output_read_enable(grn_pe_output_read_enable[36]),
    .pe_output_valid(grn_pe_output_valid[36]),
    .pe_output_data(grn_pe_output_data[36]),
    .pe_output_available(grn_pe_output_available[36])
  );


  grn_mem_pe
  grn_mem_pe_38
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[37]),
    .config_input_valid(grn_pe_config_output_valid[37]),
    .config_input(grn_pe_config_output[37]),
    .config_output_done(grn_pe_config_output_done[38]),
    .config_output_valid(grn_pe_config_output_valid[38]),
    .config_output(grn_pe_config_output[38]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[38]),
    .pe_bypass_valid(grn_pe_output_valid[38]),
    .pe_bypass_data(grn_pe_output_data[38]),
    .pe_bypass_available(grn_pe_output_available[38]),
    .pe_output_read_enable(grn_pe_output_read_enable[37]),
    .pe_output_valid(grn_pe_output_valid[37]),
    .pe_output_data(grn_pe_output_data[37]),
    .pe_output_available(grn_pe_output_available[37])
  );


  grn_mem_pe
  grn_mem_pe_39
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[38]),
    .config_input_valid(grn_pe_config_output_valid[38]),
    .config_input(grn_pe_config_output[38]),
    .config_output_done(grn_pe_config_output_done[39]),
    .config_output_valid(grn_pe_config_output_valid[39]),
    .config_output(grn_pe_config_output[39]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[39]),
    .pe_bypass_valid(grn_pe_output_valid[39]),
    .pe_bypass_data(grn_pe_output_data[39]),
    .pe_bypass_available(grn_pe_output_available[39]),
    .pe_output_read_enable(grn_pe_output_read_enable[38]),
    .pe_output_valid(grn_pe_output_valid[38]),
    .pe_output_data(grn_pe_output_data[38]),
    .pe_output_available(grn_pe_output_available[38])
  );


  grn_mem_pe
  grn_mem_pe_40
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[39]),
    .config_input_valid(grn_pe_config_output_valid[39]),
    .config_input(grn_pe_config_output[39]),
    .config_output_done(grn_pe_config_output_done[40]),
    .config_output_valid(grn_pe_config_output_valid[40]),
    .config_output(grn_pe_config_output[40]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[40]),
    .pe_bypass_valid(grn_pe_output_valid[40]),
    .pe_bypass_data(grn_pe_output_data[40]),
    .pe_bypass_available(grn_pe_output_available[40]),
    .pe_output_read_enable(grn_pe_output_read_enable[39]),
    .pe_output_valid(grn_pe_output_valid[39]),
    .pe_output_data(grn_pe_output_data[39]),
    .pe_output_available(grn_pe_output_available[39])
  );


  grn_mem_pe
  grn_mem_pe_41
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[40]),
    .config_input_valid(grn_pe_config_output_valid[40]),
    .config_input(grn_pe_config_output[40]),
    .config_output_done(grn_pe_config_output_done[41]),
    .config_output_valid(grn_pe_config_output_valid[41]),
    .config_output(grn_pe_config_output[41]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[41]),
    .pe_bypass_valid(grn_pe_output_valid[41]),
    .pe_bypass_data(grn_pe_output_data[41]),
    .pe_bypass_available(grn_pe_output_available[41]),
    .pe_output_read_enable(grn_pe_output_read_enable[40]),
    .pe_output_valid(grn_pe_output_valid[40]),
    .pe_output_data(grn_pe_output_data[40]),
    .pe_output_available(grn_pe_output_available[40])
  );


  grn_mem_pe
  grn_mem_pe_42
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[41]),
    .config_input_valid(grn_pe_config_output_valid[41]),
    .config_input(grn_pe_config_output[41]),
    .config_output_done(grn_pe_config_output_done[42]),
    .config_output_valid(grn_pe_config_output_valid[42]),
    .config_output(grn_pe_config_output[42]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[42]),
    .pe_bypass_valid(grn_pe_output_valid[42]),
    .pe_bypass_data(grn_pe_output_data[42]),
    .pe_bypass_available(grn_pe_output_available[42]),
    .pe_output_read_enable(grn_pe_output_read_enable[41]),
    .pe_output_valid(grn_pe_output_valid[41]),
    .pe_output_data(grn_pe_output_data[41]),
    .pe_output_available(grn_pe_output_available[41])
  );


  grn_mem_pe
  grn_mem_pe_43
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[42]),
    .config_input_valid(grn_pe_config_output_valid[42]),
    .config_input(grn_pe_config_output[42]),
    .config_output_done(grn_pe_config_output_done[43]),
    .config_output_valid(grn_pe_config_output_valid[43]),
    .config_output(grn_pe_config_output[43]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[43]),
    .pe_bypass_valid(grn_pe_output_valid[43]),
    .pe_bypass_data(grn_pe_output_data[43]),
    .pe_bypass_available(grn_pe_output_available[43]),
    .pe_output_read_enable(grn_pe_output_read_enable[42]),
    .pe_output_valid(grn_pe_output_valid[42]),
    .pe_output_data(grn_pe_output_data[42]),
    .pe_output_available(grn_pe_output_available[42])
  );


  grn_mem_pe
  grn_mem_pe_44
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[43]),
    .config_input_valid(grn_pe_config_output_valid[43]),
    .config_input(grn_pe_config_output[43]),
    .config_output_done(grn_pe_config_output_done[44]),
    .config_output_valid(grn_pe_config_output_valid[44]),
    .config_output(grn_pe_config_output[44]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[44]),
    .pe_bypass_valid(grn_pe_output_valid[44]),
    .pe_bypass_data(grn_pe_output_data[44]),
    .pe_bypass_available(grn_pe_output_available[44]),
    .pe_output_read_enable(grn_pe_output_read_enable[43]),
    .pe_output_valid(grn_pe_output_valid[43]),
    .pe_output_data(grn_pe_output_data[43]),
    .pe_output_available(grn_pe_output_available[43])
  );


  grn_mem_pe
  grn_mem_pe_45
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[44]),
    .config_input_valid(grn_pe_config_output_valid[44]),
    .config_input(grn_pe_config_output[44]),
    .config_output_done(grn_pe_config_output_done[45]),
    .config_output_valid(grn_pe_config_output_valid[45]),
    .config_output(grn_pe_config_output[45]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[45]),
    .pe_bypass_valid(grn_pe_output_valid[45]),
    .pe_bypass_data(grn_pe_output_data[45]),
    .pe_bypass_available(grn_pe_output_available[45]),
    .pe_output_read_enable(grn_pe_output_read_enable[44]),
    .pe_output_valid(grn_pe_output_valid[44]),
    .pe_output_data(grn_pe_output_data[44]),
    .pe_output_available(grn_pe_output_available[44])
  );


  grn_mem_pe
  grn_mem_pe_46
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[45]),
    .config_input_valid(grn_pe_config_output_valid[45]),
    .config_input(grn_pe_config_output[45]),
    .config_output_done(grn_pe_config_output_done[46]),
    .config_output_valid(grn_pe_config_output_valid[46]),
    .config_output(grn_pe_config_output[46]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[46]),
    .pe_bypass_valid(grn_pe_output_valid[46]),
    .pe_bypass_data(grn_pe_output_data[46]),
    .pe_bypass_available(grn_pe_output_available[46]),
    .pe_output_read_enable(grn_pe_output_read_enable[45]),
    .pe_output_valid(grn_pe_output_valid[45]),
    .pe_output_data(grn_pe_output_data[45]),
    .pe_output_available(grn_pe_output_available[45])
  );


  grn_mem_pe
  grn_mem_pe_47
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[46]),
    .config_input_valid(grn_pe_config_output_valid[46]),
    .config_input(grn_pe_config_output[46]),
    .config_output_done(grn_pe_config_output_done[47]),
    .config_output_valid(grn_pe_config_output_valid[47]),
    .config_output(grn_pe_config_output[47]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[47]),
    .pe_bypass_valid(grn_pe_output_valid[47]),
    .pe_bypass_data(grn_pe_output_data[47]),
    .pe_bypass_available(grn_pe_output_available[47]),
    .pe_output_read_enable(grn_pe_output_read_enable[46]),
    .pe_output_valid(grn_pe_output_valid[46]),
    .pe_output_data(grn_pe_output_data[46]),
    .pe_output_available(grn_pe_output_available[46])
  );


  grn_mem_pe
  grn_mem_pe_48
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[47]),
    .config_input_valid(grn_pe_config_output_valid[47]),
    .config_input(grn_pe_config_output[47]),
    .config_output_done(grn_pe_config_output_done[48]),
    .config_output_valid(grn_pe_config_output_valid[48]),
    .config_output(grn_pe_config_output[48]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[48]),
    .pe_bypass_valid(grn_pe_output_valid[48]),
    .pe_bypass_data(grn_pe_output_data[48]),
    .pe_bypass_available(grn_pe_output_available[48]),
    .pe_output_read_enable(grn_pe_output_read_enable[47]),
    .pe_output_valid(grn_pe_output_valid[47]),
    .pe_output_data(grn_pe_output_data[47]),
    .pe_output_available(grn_pe_output_available[47])
  );


  grn_mem_pe
  grn_mem_pe_49
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[48]),
    .config_input_valid(grn_pe_config_output_valid[48]),
    .config_input(grn_pe_config_output[48]),
    .config_output_done(grn_pe_config_output_done[49]),
    .config_output_valid(grn_pe_config_output_valid[49]),
    .config_output(grn_pe_config_output[49]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[49]),
    .pe_bypass_valid(grn_pe_output_valid[49]),
    .pe_bypass_data(grn_pe_output_data[49]),
    .pe_bypass_available(grn_pe_output_available[49]),
    .pe_output_read_enable(grn_pe_output_read_enable[48]),
    .pe_output_valid(grn_pe_output_valid[48]),
    .pe_output_data(grn_pe_output_data[48]),
    .pe_output_available(grn_pe_output_available[48])
  );


  grn_mem_pe
  grn_mem_pe_50
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[49]),
    .config_input_valid(grn_pe_config_output_valid[49]),
    .config_input(grn_pe_config_output[49]),
    .config_output_done(grn_pe_config_output_done[50]),
    .config_output_valid(grn_pe_config_output_valid[50]),
    .config_output(grn_pe_config_output[50]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[50]),
    .pe_bypass_valid(grn_pe_output_valid[50]),
    .pe_bypass_data(grn_pe_output_data[50]),
    .pe_bypass_available(grn_pe_output_available[50]),
    .pe_output_read_enable(grn_pe_output_read_enable[49]),
    .pe_output_valid(grn_pe_output_valid[49]),
    .pe_output_data(grn_pe_output_data[49]),
    .pe_output_available(grn_pe_output_available[49])
  );


  grn_mem_pe
  grn_mem_pe_51
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[50]),
    .config_input_valid(grn_pe_config_output_valid[50]),
    .config_input(grn_pe_config_output[50]),
    .config_output_done(grn_pe_config_output_done[51]),
    .config_output_valid(grn_pe_config_output_valid[51]),
    .config_output(grn_pe_config_output[51]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[51]),
    .pe_bypass_valid(grn_pe_output_valid[51]),
    .pe_bypass_data(grn_pe_output_data[51]),
    .pe_bypass_available(grn_pe_output_available[51]),
    .pe_output_read_enable(grn_pe_output_read_enable[50]),
    .pe_output_valid(grn_pe_output_valid[50]),
    .pe_output_data(grn_pe_output_data[50]),
    .pe_output_available(grn_pe_output_available[50])
  );


  grn_mem_pe
  grn_mem_pe_52
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[51]),
    .config_input_valid(grn_pe_config_output_valid[51]),
    .config_input(grn_pe_config_output[51]),
    .config_output_done(grn_pe_config_output_done[52]),
    .config_output_valid(grn_pe_config_output_valid[52]),
    .config_output(grn_pe_config_output[52]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[52]),
    .pe_bypass_valid(grn_pe_output_valid[52]),
    .pe_bypass_data(grn_pe_output_data[52]),
    .pe_bypass_available(grn_pe_output_available[52]),
    .pe_output_read_enable(grn_pe_output_read_enable[51]),
    .pe_output_valid(grn_pe_output_valid[51]),
    .pe_output_data(grn_pe_output_data[51]),
    .pe_output_available(grn_pe_output_available[51])
  );


  grn_mem_pe
  grn_mem_pe_53
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[52]),
    .config_input_valid(grn_pe_config_output_valid[52]),
    .config_input(grn_pe_config_output[52]),
    .config_output_done(grn_pe_config_output_done[53]),
    .config_output_valid(grn_pe_config_output_valid[53]),
    .config_output(grn_pe_config_output[53]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[53]),
    .pe_bypass_valid(grn_pe_output_valid[53]),
    .pe_bypass_data(grn_pe_output_data[53]),
    .pe_bypass_available(grn_pe_output_available[53]),
    .pe_output_read_enable(grn_pe_output_read_enable[52]),
    .pe_output_valid(grn_pe_output_valid[52]),
    .pe_output_data(grn_pe_output_data[52]),
    .pe_output_available(grn_pe_output_available[52])
  );


  grn_mem_pe
  grn_mem_pe_54
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[53]),
    .config_input_valid(grn_pe_config_output_valid[53]),
    .config_input(grn_pe_config_output[53]),
    .config_output_done(grn_pe_config_output_done[54]),
    .config_output_valid(grn_pe_config_output_valid[54]),
    .config_output(grn_pe_config_output[54]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[54]),
    .pe_bypass_valid(grn_pe_output_valid[54]),
    .pe_bypass_data(grn_pe_output_data[54]),
    .pe_bypass_available(grn_pe_output_available[54]),
    .pe_output_read_enable(grn_pe_output_read_enable[53]),
    .pe_output_valid(grn_pe_output_valid[53]),
    .pe_output_data(grn_pe_output_data[53]),
    .pe_output_available(grn_pe_output_available[53])
  );


  grn_mem_pe
  grn_mem_pe_55
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[54]),
    .config_input_valid(grn_pe_config_output_valid[54]),
    .config_input(grn_pe_config_output[54]),
    .config_output_done(grn_pe_config_output_done[55]),
    .config_output_valid(grn_pe_config_output_valid[55]),
    .config_output(grn_pe_config_output[55]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[55]),
    .pe_bypass_valid(grn_pe_output_valid[55]),
    .pe_bypass_data(grn_pe_output_data[55]),
    .pe_bypass_available(grn_pe_output_available[55]),
    .pe_output_read_enable(grn_pe_output_read_enable[54]),
    .pe_output_valid(grn_pe_output_valid[54]),
    .pe_output_data(grn_pe_output_data[54]),
    .pe_output_available(grn_pe_output_available[54])
  );


  grn_mem_pe
  grn_mem_pe_56
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[55]),
    .config_input_valid(grn_pe_config_output_valid[55]),
    .config_input(grn_pe_config_output[55]),
    .config_output_done(grn_pe_config_output_done[56]),
    .config_output_valid(grn_pe_config_output_valid[56]),
    .config_output(grn_pe_config_output[56]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[56]),
    .pe_bypass_valid(grn_pe_output_valid[56]),
    .pe_bypass_data(grn_pe_output_data[56]),
    .pe_bypass_available(grn_pe_output_available[56]),
    .pe_output_read_enable(grn_pe_output_read_enable[55]),
    .pe_output_valid(grn_pe_output_valid[55]),
    .pe_output_data(grn_pe_output_data[55]),
    .pe_output_available(grn_pe_output_available[55])
  );


  grn_mem_pe
  grn_mem_pe_57
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[56]),
    .config_input_valid(grn_pe_config_output_valid[56]),
    .config_input(grn_pe_config_output[56]),
    .config_output_done(grn_pe_config_output_done[57]),
    .config_output_valid(grn_pe_config_output_valid[57]),
    .config_output(grn_pe_config_output[57]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[57]),
    .pe_bypass_valid(grn_pe_output_valid[57]),
    .pe_bypass_data(grn_pe_output_data[57]),
    .pe_bypass_available(grn_pe_output_available[57]),
    .pe_output_read_enable(grn_pe_output_read_enable[56]),
    .pe_output_valid(grn_pe_output_valid[56]),
    .pe_output_data(grn_pe_output_data[56]),
    .pe_output_available(grn_pe_output_available[56])
  );


  grn_mem_pe
  grn_mem_pe_58
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[57]),
    .config_input_valid(grn_pe_config_output_valid[57]),
    .config_input(grn_pe_config_output[57]),
    .config_output_done(grn_pe_config_output_done[58]),
    .config_output_valid(grn_pe_config_output_valid[58]),
    .config_output(grn_pe_config_output[58]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[58]),
    .pe_bypass_valid(grn_pe_output_valid[58]),
    .pe_bypass_data(grn_pe_output_data[58]),
    .pe_bypass_available(grn_pe_output_available[58]),
    .pe_output_read_enable(grn_pe_output_read_enable[57]),
    .pe_output_valid(grn_pe_output_valid[57]),
    .pe_output_data(grn_pe_output_data[57]),
    .pe_output_available(grn_pe_output_available[57])
  );


  grn_mem_pe
  grn_mem_pe_59
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[58]),
    .config_input_valid(grn_pe_config_output_valid[58]),
    .config_input(grn_pe_config_output[58]),
    .config_output_done(grn_pe_config_output_done[59]),
    .config_output_valid(grn_pe_config_output_valid[59]),
    .config_output(grn_pe_config_output[59]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[59]),
    .pe_bypass_valid(grn_pe_output_valid[59]),
    .pe_bypass_data(grn_pe_output_data[59]),
    .pe_bypass_available(grn_pe_output_available[59]),
    .pe_output_read_enable(grn_pe_output_read_enable[58]),
    .pe_output_valid(grn_pe_output_valid[58]),
    .pe_output_data(grn_pe_output_data[58]),
    .pe_output_available(grn_pe_output_available[58])
  );


  grn_mem_pe
  grn_mem_pe_60
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[59]),
    .config_input_valid(grn_pe_config_output_valid[59]),
    .config_input(grn_pe_config_output[59]),
    .config_output_done(grn_pe_config_output_done[60]),
    .config_output_valid(grn_pe_config_output_valid[60]),
    .config_output(grn_pe_config_output[60]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[60]),
    .pe_bypass_valid(grn_pe_output_valid[60]),
    .pe_bypass_data(grn_pe_output_data[60]),
    .pe_bypass_available(grn_pe_output_available[60]),
    .pe_output_read_enable(grn_pe_output_read_enable[59]),
    .pe_output_valid(grn_pe_output_valid[59]),
    .pe_output_data(grn_pe_output_data[59]),
    .pe_output_available(grn_pe_output_available[59])
  );


  grn_mem_pe
  grn_mem_pe_61
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[60]),
    .config_input_valid(grn_pe_config_output_valid[60]),
    .config_input(grn_pe_config_output[60]),
    .config_output_done(grn_pe_config_output_done[61]),
    .config_output_valid(grn_pe_config_output_valid[61]),
    .config_output(grn_pe_config_output[61]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[61]),
    .pe_bypass_valid(grn_pe_output_valid[61]),
    .pe_bypass_data(grn_pe_output_data[61]),
    .pe_bypass_available(grn_pe_output_available[61]),
    .pe_output_read_enable(grn_pe_output_read_enable[60]),
    .pe_output_valid(grn_pe_output_valid[60]),
    .pe_output_data(grn_pe_output_data[60]),
    .pe_output_available(grn_pe_output_available[60])
  );


  grn_mem_pe
  grn_mem_pe_62
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[61]),
    .config_input_valid(grn_pe_config_output_valid[61]),
    .config_input(grn_pe_config_output[61]),
    .config_output_done(grn_pe_config_output_done[62]),
    .config_output_valid(grn_pe_config_output_valid[62]),
    .config_output(grn_pe_config_output[62]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[62]),
    .pe_bypass_valid(grn_pe_output_valid[62]),
    .pe_bypass_data(grn_pe_output_data[62]),
    .pe_bypass_available(grn_pe_output_available[62]),
    .pe_output_read_enable(grn_pe_output_read_enable[61]),
    .pe_output_valid(grn_pe_output_valid[61]),
    .pe_output_data(grn_pe_output_data[61]),
    .pe_output_available(grn_pe_output_available[61])
  );


  grn_mem_pe
  grn_mem_pe_63
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[62]),
    .config_input_valid(grn_pe_config_output_valid[62]),
    .config_input(grn_pe_config_output[62]),
    .config_output_done(grn_pe_config_output_done[63]),
    .config_output_valid(grn_pe_config_output_valid[63]),
    .config_output(grn_pe_config_output[63]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[63]),
    .pe_bypass_valid(grn_pe_output_valid[63]),
    .pe_bypass_data(grn_pe_output_data[63]),
    .pe_bypass_available(grn_pe_output_available[63]),
    .pe_output_read_enable(grn_pe_output_read_enable[62]),
    .pe_output_valid(grn_pe_output_valid[62]),
    .pe_output_data(grn_pe_output_data[62]),
    .pe_output_available(grn_pe_output_available[62])
  );


  grn_mem_pe
  grn_mem_pe_64
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[63]),
    .config_input_valid(grn_pe_config_output_valid[63]),
    .config_input(grn_pe_config_output[63]),
    .config_output_done(grn_pe_config_output_done[64]),
    .config_output_valid(grn_pe_config_output_valid[64]),
    .config_output(grn_pe_config_output[64]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[64]),
    .pe_bypass_valid(grn_pe_output_valid[64]),
    .pe_bypass_data(grn_pe_output_data[64]),
    .pe_bypass_available(grn_pe_output_available[64]),
    .pe_output_read_enable(grn_pe_output_read_enable[63]),
    .pe_output_valid(grn_pe_output_valid[63]),
    .pe_output_data(grn_pe_output_data[63]),
    .pe_output_available(grn_pe_output_available[63])
  );


  grn_mem_pe
  grn_mem_pe_65
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[64]),
    .config_input_valid(grn_pe_config_output_valid[64]),
    .config_input(grn_pe_config_output[64]),
    .config_output_done(grn_pe_config_output_done[65]),
    .config_output_valid(grn_pe_config_output_valid[65]),
    .config_output(grn_pe_config_output[65]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[65]),
    .pe_bypass_valid(grn_pe_output_valid[65]),
    .pe_bypass_data(grn_pe_output_data[65]),
    .pe_bypass_available(grn_pe_output_available[65]),
    .pe_output_read_enable(grn_pe_output_read_enable[64]),
    .pe_output_valid(grn_pe_output_valid[64]),
    .pe_output_data(grn_pe_output_data[64]),
    .pe_output_available(grn_pe_output_available[64])
  );


  grn_mem_pe
  grn_mem_pe_66
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[65]),
    .config_input_valid(grn_pe_config_output_valid[65]),
    .config_input(grn_pe_config_output[65]),
    .config_output_done(grn_pe_config_output_done[66]),
    .config_output_valid(grn_pe_config_output_valid[66]),
    .config_output(grn_pe_config_output[66]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[66]),
    .pe_bypass_valid(grn_pe_output_valid[66]),
    .pe_bypass_data(grn_pe_output_data[66]),
    .pe_bypass_available(grn_pe_output_available[66]),
    .pe_output_read_enable(grn_pe_output_read_enable[65]),
    .pe_output_valid(grn_pe_output_valid[65]),
    .pe_output_data(grn_pe_output_data[65]),
    .pe_output_available(grn_pe_output_available[65])
  );


  grn_mem_pe
  grn_mem_pe_67
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[66]),
    .config_input_valid(grn_pe_config_output_valid[66]),
    .config_input(grn_pe_config_output[66]),
    .config_output_done(grn_pe_config_output_done[67]),
    .config_output_valid(grn_pe_config_output_valid[67]),
    .config_output(grn_pe_config_output[67]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[67]),
    .pe_bypass_valid(grn_pe_output_valid[67]),
    .pe_bypass_data(grn_pe_output_data[67]),
    .pe_bypass_available(grn_pe_output_available[67]),
    .pe_output_read_enable(grn_pe_output_read_enable[66]),
    .pe_output_valid(grn_pe_output_valid[66]),
    .pe_output_data(grn_pe_output_data[66]),
    .pe_output_available(grn_pe_output_available[66])
  );


  grn_mem_pe
  grn_mem_pe_68
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[67]),
    .config_input_valid(grn_pe_config_output_valid[67]),
    .config_input(grn_pe_config_output[67]),
    .config_output_done(grn_pe_config_output_done[68]),
    .config_output_valid(grn_pe_config_output_valid[68]),
    .config_output(grn_pe_config_output[68]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[68]),
    .pe_bypass_valid(grn_pe_output_valid[68]),
    .pe_bypass_data(grn_pe_output_data[68]),
    .pe_bypass_available(grn_pe_output_available[68]),
    .pe_output_read_enable(grn_pe_output_read_enable[67]),
    .pe_output_valid(grn_pe_output_valid[67]),
    .pe_output_data(grn_pe_output_data[67]),
    .pe_output_available(grn_pe_output_available[67])
  );


  grn_mem_pe
  grn_mem_pe_69
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[68]),
    .config_input_valid(grn_pe_config_output_valid[68]),
    .config_input(grn_pe_config_output[68]),
    .config_output_done(grn_pe_config_output_done[69]),
    .config_output_valid(grn_pe_config_output_valid[69]),
    .config_output(grn_pe_config_output[69]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[69]),
    .pe_bypass_valid(grn_pe_output_valid[69]),
    .pe_bypass_data(grn_pe_output_data[69]),
    .pe_bypass_available(grn_pe_output_available[69]),
    .pe_output_read_enable(grn_pe_output_read_enable[68]),
    .pe_output_valid(grn_pe_output_valid[68]),
    .pe_output_data(grn_pe_output_data[68]),
    .pe_output_available(grn_pe_output_available[68])
  );


  grn_mem_pe
  grn_mem_pe_70
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[69]),
    .config_input_valid(grn_pe_config_output_valid[69]),
    .config_input(grn_pe_config_output[69]),
    .config_output_done(grn_pe_config_output_done[70]),
    .config_output_valid(grn_pe_config_output_valid[70]),
    .config_output(grn_pe_config_output[70]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[70]),
    .pe_bypass_valid(grn_pe_output_valid[70]),
    .pe_bypass_data(grn_pe_output_data[70]),
    .pe_bypass_available(grn_pe_output_available[70]),
    .pe_output_read_enable(grn_pe_output_read_enable[69]),
    .pe_output_valid(grn_pe_output_valid[69]),
    .pe_output_data(grn_pe_output_data[69]),
    .pe_output_available(grn_pe_output_available[69])
  );


  grn_mem_pe
  grn_mem_pe_71
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[70]),
    .config_input_valid(grn_pe_config_output_valid[70]),
    .config_input(grn_pe_config_output[70]),
    .config_output_done(grn_pe_config_output_done[71]),
    .config_output_valid(grn_pe_config_output_valid[71]),
    .config_output(grn_pe_config_output[71]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[71]),
    .pe_bypass_valid(grn_pe_output_valid[71]),
    .pe_bypass_data(grn_pe_output_data[71]),
    .pe_bypass_available(grn_pe_output_available[71]),
    .pe_output_read_enable(grn_pe_output_read_enable[70]),
    .pe_output_valid(grn_pe_output_valid[70]),
    .pe_output_data(grn_pe_output_data[70]),
    .pe_output_available(grn_pe_output_available[70])
  );


  grn_mem_pe
  grn_mem_pe_72
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[71]),
    .config_input_valid(grn_pe_config_output_valid[71]),
    .config_input(grn_pe_config_output[71]),
    .config_output_done(grn_pe_config_output_done[72]),
    .config_output_valid(grn_pe_config_output_valid[72]),
    .config_output(grn_pe_config_output[72]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[72]),
    .pe_bypass_valid(grn_pe_output_valid[72]),
    .pe_bypass_data(grn_pe_output_data[72]),
    .pe_bypass_available(grn_pe_output_available[72]),
    .pe_output_read_enable(grn_pe_output_read_enable[71]),
    .pe_output_valid(grn_pe_output_valid[71]),
    .pe_output_data(grn_pe_output_data[71]),
    .pe_output_available(grn_pe_output_available[71])
  );


  grn_mem_pe
  grn_mem_pe_73
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[72]),
    .config_input_valid(grn_pe_config_output_valid[72]),
    .config_input(grn_pe_config_output[72]),
    .config_output_done(grn_pe_config_output_done[73]),
    .config_output_valid(grn_pe_config_output_valid[73]),
    .config_output(grn_pe_config_output[73]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[73]),
    .pe_bypass_valid(grn_pe_output_valid[73]),
    .pe_bypass_data(grn_pe_output_data[73]),
    .pe_bypass_available(grn_pe_output_available[73]),
    .pe_output_read_enable(grn_pe_output_read_enable[72]),
    .pe_output_valid(grn_pe_output_valid[72]),
    .pe_output_data(grn_pe_output_data[72]),
    .pe_output_available(grn_pe_output_available[72])
  );


  grn_mem_pe
  grn_mem_pe_74
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[73]),
    .config_input_valid(grn_pe_config_output_valid[73]),
    .config_input(grn_pe_config_output[73]),
    .config_output_done(grn_pe_config_output_done[74]),
    .config_output_valid(grn_pe_config_output_valid[74]),
    .config_output(grn_pe_config_output[74]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[74]),
    .pe_bypass_valid(grn_pe_output_valid[74]),
    .pe_bypass_data(grn_pe_output_data[74]),
    .pe_bypass_available(grn_pe_output_available[74]),
    .pe_output_read_enable(grn_pe_output_read_enable[73]),
    .pe_output_valid(grn_pe_output_valid[73]),
    .pe_output_data(grn_pe_output_data[73]),
    .pe_output_available(grn_pe_output_available[73])
  );


  grn_mem_pe
  grn_mem_pe_75
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[74]),
    .config_input_valid(grn_pe_config_output_valid[74]),
    .config_input(grn_pe_config_output[74]),
    .config_output_done(grn_pe_config_output_done[75]),
    .config_output_valid(grn_pe_config_output_valid[75]),
    .config_output(grn_pe_config_output[75]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[75]),
    .pe_bypass_valid(grn_pe_output_valid[75]),
    .pe_bypass_data(grn_pe_output_data[75]),
    .pe_bypass_available(grn_pe_output_available[75]),
    .pe_output_read_enable(grn_pe_output_read_enable[74]),
    .pe_output_valid(grn_pe_output_valid[74]),
    .pe_output_data(grn_pe_output_data[74]),
    .pe_output_available(grn_pe_output_available[74])
  );


  grn_mem_pe
  grn_mem_pe_76
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[75]),
    .config_input_valid(grn_pe_config_output_valid[75]),
    .config_input(grn_pe_config_output[75]),
    .config_output_done(grn_pe_config_output_done[76]),
    .config_output_valid(grn_pe_config_output_valid[76]),
    .config_output(grn_pe_config_output[76]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[76]),
    .pe_bypass_valid(grn_pe_output_valid[76]),
    .pe_bypass_data(grn_pe_output_data[76]),
    .pe_bypass_available(grn_pe_output_available[76]),
    .pe_output_read_enable(grn_pe_output_read_enable[75]),
    .pe_output_valid(grn_pe_output_valid[75]),
    .pe_output_data(grn_pe_output_data[75]),
    .pe_output_available(grn_pe_output_available[75])
  );


  grn_mem_pe
  grn_mem_pe_77
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[76]),
    .config_input_valid(grn_pe_config_output_valid[76]),
    .config_input(grn_pe_config_output[76]),
    .config_output_done(grn_pe_config_output_done[77]),
    .config_output_valid(grn_pe_config_output_valid[77]),
    .config_output(grn_pe_config_output[77]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[77]),
    .pe_bypass_valid(grn_pe_output_valid[77]),
    .pe_bypass_data(grn_pe_output_data[77]),
    .pe_bypass_available(grn_pe_output_available[77]),
    .pe_output_read_enable(grn_pe_output_read_enable[76]),
    .pe_output_valid(grn_pe_output_valid[76]),
    .pe_output_data(grn_pe_output_data[76]),
    .pe_output_available(grn_pe_output_available[76])
  );


  grn_mem_pe
  grn_mem_pe_78
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[77]),
    .config_input_valid(grn_pe_config_output_valid[77]),
    .config_input(grn_pe_config_output[77]),
    .config_output_done(grn_pe_config_output_done[78]),
    .config_output_valid(grn_pe_config_output_valid[78]),
    .config_output(grn_pe_config_output[78]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[78]),
    .pe_bypass_valid(grn_pe_output_valid[78]),
    .pe_bypass_data(grn_pe_output_data[78]),
    .pe_bypass_available(grn_pe_output_available[78]),
    .pe_output_read_enable(grn_pe_output_read_enable[77]),
    .pe_output_valid(grn_pe_output_valid[77]),
    .pe_output_data(grn_pe_output_data[77]),
    .pe_output_available(grn_pe_output_available[77])
  );


  grn_mem_pe
  grn_mem_pe_79
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[78]),
    .config_input_valid(grn_pe_config_output_valid[78]),
    .config_input(grn_pe_config_output[78]),
    .config_output_done(grn_pe_config_output_done[79]),
    .config_output_valid(grn_pe_config_output_valid[79]),
    .config_output(grn_pe_config_output[79]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[79]),
    .pe_bypass_valid(grn_pe_output_valid[79]),
    .pe_bypass_data(grn_pe_output_data[79]),
    .pe_bypass_available(grn_pe_output_available[79]),
    .pe_output_read_enable(grn_pe_output_read_enable[78]),
    .pe_output_valid(grn_pe_output_valid[78]),
    .pe_output_data(grn_pe_output_data[78]),
    .pe_output_available(grn_pe_output_available[78])
  );

  //PE modules instantiation - End

  initial begin
    grn_aws_request_read = 0;
    grn_aws_request_write = 0;
    grn_aws_write_data = 0;
    fms_cs = 0;
    config_valid = 0;
    config_data = 0;
    config_done = 0;
    flag = 0;
    consume_rd_enable = 0;
    fsm_consume_data = 0;
  end


endmodule



module grn_mem_pe
(
  input clk,
  input rst,
  input config_input_done,
  input config_input_valid,
  input [32-1:0] config_input,
  output reg config_output_done,
  output reg config_output_valid,
  output reg [32-1:0] config_output,
  output reg pe_bypass_read_enable,
  input pe_bypass_valid,
  input [32-1:0] pe_bypass_data,
  input pe_bypass_available,
  input pe_output_read_enable,
  output pe_output_valid,
  output [32-1:0] pe_output_data,
  output pe_output_available
);


  //configuration wires and regs - begin
  reg is_configured;
  wire [96-1:0] pe_init_conf;
  wire [96-1:0] pe_end_conf;
  reg [192-1:0] pe_data_conf;
  reg [3-1:0] config_counter;
  reg [448-1:0] pe_eq_conf;
  reg [4-1:0] config_eq_counter;
  assign pe_init_conf = pe_data_conf[95:0];
  assign pe_end_conf = pe_data_conf[191:96];
  //configuration wires and regs - end

  // regs and wires to control the grn core
  reg start_grn;
  wire [70-1:0] grn_initial_state;
  wire [70-1:0] grn_final_state;
  wire [430-1:0] grn_equations_config;
  reg grn_output_read_enable;
  wire grn_output_valid;
  wire [32-1:0] grn_output_data;
  wire grn_output_available;
  reg [3-1:0] fsm_pe_jo;
  localparam fsm_pe_jo_look_grn = 0;
  localparam fsm_pe_jo_rd_grn = 1;
  localparam fsm_pe_jo_wr_grn = 2;
  localparam fsm_pe_jo_look_pe = 3;
  localparam fsm_pe_jo_rd_pe = 4;
  localparam fsm_pe_jo_wr_pe = 5;
  reg [3-1:0] rd_wr_counter;

  //Fifo out wires and regs
  reg fifo_out_write_enable;
  reg [32-1:0] fifo_out_input_data;
  wire fifo_out_empty;
  wire fifo_out_full;

  //configuration sector - begin
  reg [2-1:0] fsm_config;
  localparam fsm_config_mem_config = 0;
  localparam fsm_config_other = 1;
  localparam fsm_config_done = 2;

  always @(posedge clk) begin
    config_output_valid <= 0;
    config_output <= config_input;
    config_output_done <= config_input_done;
    if(rst) begin
      is_configured <= 0;
      config_counter <= 0;
      config_eq_counter <= 0;
      fsm_config <= fsm_config_mem_config;
    end else begin
      case(fsm_config)
        fsm_config_mem_config: begin
          if(config_input_valid) begin
            config_eq_counter <= config_eq_counter + 1;
            if(config_eq_counter == 13) begin
              fsm_config <= fsm_config_other;
            end 
            pe_eq_conf <= { config_input, pe_eq_conf[447:32] };
            config_output_valid <= config_input_valid;
          end 
        end
        fsm_config_other: begin
          if(config_input_valid) begin
            config_counter <= config_counter + 1;
            if(config_counter == 5) begin
              is_configured <= 1;
              fsm_config <= fsm_config_done;
            end 
            pe_data_conf <= { config_input, pe_data_conf[191:32] };
          end 
        end
        fsm_config_done: begin
          config_output_valid <= config_input_valid;
        end
      endcase
    end
  end

  //configuration sector - end

  //execution sector - begin

  always @(posedge clk) begin
    if(rst) begin
      start_grn <= 0;
      grn_output_read_enable <= 0;
      fifo_out_write_enable <= 0;
      pe_bypass_read_enable <= 0;
      fsm_pe_jo <= fsm_pe_jo_look_grn;
    end else begin
      if(is_configured) begin
        start_grn <= 1;
        grn_output_read_enable <= 0;
        fifo_out_write_enable <= 0;
        pe_bypass_read_enable <= 0;
        case(fsm_pe_jo)
          fsm_pe_jo_look_grn: begin
            fsm_pe_jo <= fsm_pe_jo_look_pe;
            if(grn_output_available) begin
              rd_wr_counter <= 0;
              fsm_pe_jo <= fsm_pe_jo_rd_grn;
            end 
          end
          fsm_pe_jo_rd_grn: begin
            if(&{ grn_output_available, ~fifo_out_full }) begin
              grn_output_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_grn;
            end 
          end
          fsm_pe_jo_wr_grn: begin
            if(grn_output_valid) begin
              fsm_pe_jo <= fsm_pe_jo_rd_grn;
              if(rd_wr_counter == 7) begin
                fsm_pe_jo <= fsm_pe_jo_look_pe;
              end 
              fifo_out_input_data <= grn_output_data;
              rd_wr_counter <= rd_wr_counter + 1;
              fifo_out_write_enable <= 1;
            end 
          end
          fsm_pe_jo_look_pe: begin
            fsm_pe_jo <= fsm_pe_jo_look_grn;
            if(pe_bypass_available) begin
              rd_wr_counter <= 0;
              fsm_pe_jo <= fsm_pe_jo_rd_pe;
            end 
          end
          fsm_pe_jo_rd_pe: begin
            if(&{ pe_bypass_available, ~fifo_out_full }) begin
              pe_bypass_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_pe;
            end 
          end
          fsm_pe_jo_wr_pe: begin
            if(pe_bypass_valid) begin
              fsm_pe_jo <= fsm_pe_jo_rd_pe;
              if(rd_wr_counter == 7) begin
                fsm_pe_jo <= fsm_pe_jo_look_grn;
              end 
              fifo_out_input_data <= pe_bypass_data;
              fifo_out_write_enable <= 1;
              rd_wr_counter <= rd_wr_counter + 1;
            end 
          end
        endcase
      end 
    end
  end

  // Grn core instantiation
  assign grn_initial_state = pe_init_conf[69:0];
  assign grn_final_state = pe_end_conf[69:0];
  assign grn_equations_config = pe_eq_conf[429:0];

  grn_mem_core
  grn_mem_core
  (
    .clk(clk),
    .rst(rst),
    .start(start_grn),
    .initial_state(grn_initial_state),
    .final_state(grn_final_state),
    .equations_config(grn_equations_config),
    .output_read_enable(grn_output_read_enable),
    .output_valid(grn_output_valid),
    .output_data(grn_output_data),
    .output_available(grn_output_available)
  );

  assign pe_output_available = ~fifo_out_empty;

  fifo
  #(
    .FIFO_WIDTH(32),
    .FIFO_DEPTH_BITS(6)
  )
  pe_mem_fifo_out
  (
    .clk(clk),
    .rst(rst),
    .write_enable(fifo_out_write_enable),
    .input_data(fifo_out_input_data),
    .output_read_enable(pe_output_read_enable),
    .output_valid(pe_output_valid),
    .output_data(pe_output_data),
    .empty(fifo_out_empty),
    .almostfull(fifo_out_full)
  );


  initial begin
    config_output_done = 0;
    config_output_valid = 0;
    config_output = 0;
    pe_bypass_read_enable = 0;
    is_configured = 0;
    pe_data_conf = 0;
    config_counter = 0;
    pe_eq_conf = 0;
    config_eq_counter = 0;
    start_grn = 0;
    grn_output_read_enable = 0;
    fsm_pe_jo = 0;
    rd_wr_counter = 0;
    fifo_out_write_enable = 0;
    fifo_out_input_data = 0;
    fsm_config = 0;
  end


endmodule



module grn_mem_core
(
  input clk,
  input rst,
  input start,
  input [70-1:0] initial_state,
  input [70-1:0] final_state,
  input [430-1:0] equations_config,
  input output_read_enable,
  output output_valid,
  output [32-1:0] output_data,
  output output_available
);

  // The grn mem core configuration consists in two buses with the initial state and the final state to be
  // searched and the content of a 1 bit memory for each equation.
  // The mem kernel output data is the FIFO data output that contains all the data found.

  //Fifo wires and regs
  reg fifo_write_enable;
  reg [32-1:0] fifo_input_data;
  wire fifo_full;
  wire fifo_empty;

  // Wires and regs to be used in control and execution of the grn mem
  reg [70-1:0] actual_state_s1;
  wire [70-1:0] next_state_s1;
  reg [70-1:0] actual_state_s2;
  wire [70-1:0] next_state_s2;
  reg [70-1:0] exec_state;
  reg flag_pulse;
  reg flag_first_it;
  reg [32-1:0] transient_counter;
  reg [32-1:0] period_counter;
  reg [256-1:0] data_to_write;
  reg [3-1:0] write_counter;

  // Here are the GRN eq_wires to be used in the core execution are created
  wire [2-1:0] eq_ATM;
  wire [4-1:0] eq_ASK1;
  wire [8-1:0] eq_AKT;
  wire [16-1:0] eq_BAX;
  wire [2-1:0] eq_APC;
  wire [4-1:0] eq_BCATENIN;
  wire [16-1:0] eq_BCL2;
  wire [8-1:0] eq_CASP3;
  wire [8-1:0] eq_CASP8;
  wire [8-1:0] eq_CASP9;
  wire [4-1:0] eq_CERAMIDE;
  wire [2-1:0] eq_CFLIP;
  wire [4-1:0] eq_COX2;
  wire [16-1:0] eq_CYCLIND1;
  wire [2-1:0] eq_CYTC;
  wire [2-1:0] eq_EP2;
  wire [2-1:0] eq_ERK;
  wire [2-1:0] eq_FAS;
  wire [4-1:0] eq_FADD;
  wire [2-1:0] eq_FOS;
  wire [2-1:0] eq_GP130;
  wire [4-1:0] eq_GSK3B;
  wire [8-1:0] eq_IAP;
  wire [2-1:0] eq_IKB;
  wire [8-1:0] eq_IKK;
  wire [4-1:0] eq_JAK;
  wire [4-1:0] eq_JNK;
  wire [16-1:0] eq_JUN;
  wire [16-1:0] eq_MDM2;
  wire [4-1:0] eq_MEK;
  wire [8-1:0] eq_MEKK1;
  wire [16-1:0] eq_MOMP;
  wire [2-1:0] eq_NFKB;
  wire [16-1:0] eq_P21;
  wire [16-1:0] eq_P53;
  wire [2-1:0] eq_PGE2;
  wire [8-1:0] eq_PI3K;
  wire [4-1:0] eq_PP2A;
  wire [8-1:0] eq_PTEN;
  wire [4-1:0] eq_RAF;
  wire [4-1:0] eq_RAS;
  wire [4-1:0] eq_ROS;
  wire [4-1:0] eq_SOD;
  wire [2-1:0] eq_S1P;
  wire [2-1:0] eq_SMAC;
  wire [4-1:0] eq_SMAD;
  wire [4-1:0] eq_SMAD7;
  wire [4-1:0] eq_SMASE;
  wire [4-1:0] eq_SPHK1;
  wire [2-1:0] eq_STAT3;
  wire [2-1:0] eq_SOCS;
  wire [4-1:0] eq_TBID;
  wire [4-1:0] eq_TGFR;
  wire [2-1:0] eq_TNFR;
  wire [8-1:0] eq_TREG;
  wire [2-1:0] eq_TNFA;
  wire [8-1:0] eq_TH2;
  wire [32-1:0] eq_TH1;
  wire [2-1:0] eq_TGFB;
  wire [8-1:0] eq_MAC;
  wire [8-1:0] eq_IL6;
  wire [4-1:0] eq_IL4;
  wire [4-1:0] eq_IL12;
  wire [4-1:0] eq_IL10;
  wire [4-1:0] eq_IFNG;
  wire [4-1:0] eq_CTL;
  wire [8-1:0] eq_DC;
  wire [2-1:0] eq_CCL2;
  wire [16-1:0] eq_Proliferation;
  wire [2-1:0] eq_Apoptosis;
  assign eq_ATM = equations_config[1:0];
  assign eq_ASK1 = equations_config[5:2];
  assign eq_AKT = equations_config[13:6];
  assign eq_BAX = equations_config[29:14];
  assign eq_APC = equations_config[31:30];
  assign eq_BCATENIN = equations_config[35:32];
  assign eq_BCL2 = equations_config[51:36];
  assign eq_CASP3 = equations_config[59:52];
  assign eq_CASP8 = equations_config[67:60];
  assign eq_CASP9 = equations_config[75:68];
  assign eq_CERAMIDE = equations_config[79:76];
  assign eq_CFLIP = equations_config[81:80];
  assign eq_COX2 = equations_config[85:82];
  assign eq_CYCLIND1 = equations_config[101:86];
  assign eq_CYTC = equations_config[103:102];
  assign eq_EP2 = equations_config[105:104];
  assign eq_ERK = equations_config[107:106];
  assign eq_FAS = equations_config[109:108];
  assign eq_FADD = equations_config[113:110];
  assign eq_FOS = equations_config[115:114];
  assign eq_GP130 = equations_config[117:116];
  assign eq_GSK3B = equations_config[121:118];
  assign eq_IAP = equations_config[129:122];
  assign eq_IKB = equations_config[131:130];
  assign eq_IKK = equations_config[139:132];
  assign eq_JAK = equations_config[143:140];
  assign eq_JNK = equations_config[147:144];
  assign eq_JUN = equations_config[163:148];
  assign eq_MDM2 = equations_config[179:164];
  assign eq_MEK = equations_config[183:180];
  assign eq_MEKK1 = equations_config[191:184];
  assign eq_MOMP = equations_config[207:192];
  assign eq_NFKB = equations_config[209:208];
  assign eq_P21 = equations_config[225:210];
  assign eq_P53 = equations_config[241:226];
  assign eq_PGE2 = equations_config[243:242];
  assign eq_PI3K = equations_config[251:244];
  assign eq_PP2A = equations_config[255:252];
  assign eq_PTEN = equations_config[263:256];
  assign eq_RAF = equations_config[267:264];
  assign eq_RAS = equations_config[271:268];
  assign eq_ROS = equations_config[275:272];
  assign eq_SOD = equations_config[279:276];
  assign eq_S1P = equations_config[281:280];
  assign eq_SMAC = equations_config[283:282];
  assign eq_SMAD = equations_config[287:284];
  assign eq_SMAD7 = equations_config[291:288];
  assign eq_SMASE = equations_config[295:292];
  assign eq_SPHK1 = equations_config[299:296];
  assign eq_STAT3 = equations_config[301:300];
  assign eq_SOCS = equations_config[303:302];
  assign eq_TBID = equations_config[307:304];
  assign eq_TGFR = equations_config[311:308];
  assign eq_TNFR = equations_config[313:312];
  assign eq_TREG = equations_config[321:314];
  assign eq_TNFA = equations_config[323:322];
  assign eq_TH2 = equations_config[331:324];
  assign eq_TH1 = equations_config[363:332];
  assign eq_TGFB = equations_config[365:364];
  assign eq_MAC = equations_config[373:366];
  assign eq_IL6 = equations_config[381:374];
  assign eq_IL4 = equations_config[385:382];
  assign eq_IL12 = equations_config[389:386];
  assign eq_IL10 = equations_config[393:390];
  assign eq_IFNG = equations_config[397:394];
  assign eq_CTL = equations_config[401:398];
  assign eq_DC = equations_config[409:402];
  assign eq_CCL2 = equations_config[411:410];
  assign eq_Proliferation = equations_config[427:412];
  assign eq_Apoptosis = equations_config[429:428];

  // State machine to control the grn algorithm execution
  reg [3-1:0] fsm_mem;
  localparam fsm_mem_set = 0;
  localparam fsm_mem_init = 1;
  localparam fsm_mem_transient_finder = 2;
  localparam fsm_mem_period_finder = 3;
  localparam fsm_mem_prepare_to_write = 4;
  localparam fsm_mem_write = 5;
  localparam fsm_mem_verify = 6;
  localparam fsm_mem_done = 7;

  always @(posedge clk) begin
    if(rst) begin
      fifo_write_enable <= 0;
      fsm_mem <= fsm_mem_set;
    end else begin
      if(start) begin
        fifo_write_enable <= 0;
        case(fsm_mem)
          fsm_mem_set: begin
            exec_state <= initial_state;
            fsm_mem <= fsm_mem_init;
          end
          fsm_mem_init: begin
            actual_state_s1 <= exec_state;
            actual_state_s2 <= exec_state;
            transient_counter <= 0;
            period_counter <= 0;
            flag_first_it <= 1;
            flag_pulse <= 0;
            fsm_mem <= fsm_mem_transient_finder;
          end
          fsm_mem_transient_finder: begin
            flag_first_it <= 0;
            if((actual_state_s1 == actual_state_s2) && ~flag_first_it && ~flag_pulse) begin
              flag_first_it <= 1;
              fsm_mem <= fsm_mem_period_finder;
            end else begin
              actual_state_s2 <= next_state_s2;
              if(flag_pulse) begin
                transient_counter <= transient_counter + 1;
                flag_pulse <= 0;
              end else begin
                flag_pulse <= 1;
                actual_state_s1 <= next_state_s1;
              end
            end
          end
          fsm_mem_period_finder: begin
            flag_first_it <= 0;
            if((actual_state_s1 == actual_state_s2) && ~flag_first_it) begin
              period_counter <= period_counter - 1;
              fsm_mem <= fsm_mem_prepare_to_write;
            end else begin
              actual_state_s2 <= next_state_s2;
              period_counter <= period_counter + 1;
            end
          end
          fsm_mem_prepare_to_write: begin
            data_to_write <= { 26'b0, exec_state, 26'b0, actual_state_s1, transient_counter, period_counter };
            fsm_mem <= fsm_mem_write;
            write_counter <= 0;
          end
          fsm_mem_write: begin
            if(write_counter == 7) begin
              fsm_mem <= fsm_mem_verify;
            end 
            if(~fifo_full) begin
              write_counter <= write_counter + 1;
              fifo_write_enable <= 1;
              data_to_write <= { 32'b0, data_to_write[255:32] };
              fifo_input_data <= data_to_write[31:0];
            end 
          end
          fsm_mem_verify: begin
            if(exec_state == final_state) begin
              fsm_mem <= fsm_mem_done;
            end else begin
              exec_state <= exec_state + 1;
              fsm_mem <= fsm_mem_init;
            end
          end
          fsm_mem_done: begin
          end
        endcase
      end 
    end
  end


  // Assigns to define each bit is used on each equation memory
  assign next_state_s1[0] = eq_ATM[{actual_state_s1[41]}];
  assign next_state_s2[0] = eq_ATM[{actual_state_s2[41]}];
  assign next_state_s1[1] = eq_ASK1[{actual_state_s1[41],actual_state_s1[33]}];
  assign next_state_s2[1] = eq_ASK1[{actual_state_s2[41],actual_state_s2[33]}];
  assign next_state_s1[2] = eq_AKT[{actual_state_s1[37],actual_state_s1[36],actual_state_s1[7]}];
  assign next_state_s2[2] = eq_AKT[{actual_state_s2[37],actual_state_s2[36],actual_state_s2[7]}];
  assign next_state_s1[3] = eq_BAX[{actual_state_s1[51],actual_state_s1[37],actual_state_s1[34],actual_state_s1[2]}];
  assign next_state_s2[3] = eq_BAX[{actual_state_s2[51],actual_state_s2[37],actual_state_s2[34],actual_state_s2[2]}];
  assign next_state_s1[4] = eq_APC[{actual_state_s1[4]}];
  assign next_state_s2[4] = eq_APC[{actual_state_s2[4]}];
  assign next_state_s1[5] = eq_BCATENIN[{actual_state_s1[21],actual_state_s1[4]}];
  assign next_state_s2[5] = eq_BCATENIN[{actual_state_s2[21],actual_state_s2[4]}];
  assign next_state_s1[6] = eq_BCL2[{actual_state_s1[49],actual_state_s1[37],actual_state_s1[34],actual_state_s1[32]}];
  assign next_state_s2[6] = eq_BCL2[{actual_state_s2[49],actual_state_s2[37],actual_state_s2[34],actual_state_s2[32]}];
  assign next_state_s1[7] = eq_CASP3[{actual_state_s1[22],actual_state_s1[9],actual_state_s1[8]}];
  assign next_state_s2[7] = eq_CASP3[{actual_state_s2[22],actual_state_s2[9],actual_state_s2[8]}];
  assign next_state_s1[8] = eq_CASP8[{actual_state_s1[33],actual_state_s1[18],actual_state_s1[11]}];
  assign next_state_s2[8] = eq_CASP8[{actual_state_s2[33],actual_state_s2[18],actual_state_s2[11]}];
  assign next_state_s1[9] = eq_CASP9[{actual_state_s1[33],actual_state_s1[22],actual_state_s1[14]}];
  assign next_state_s2[9] = eq_CASP9[{actual_state_s2[33],actual_state_s2[22],actual_state_s2[14]}];
  assign next_state_s1[10] = eq_CERAMIDE[{actual_state_s1[48],actual_state_s1[47]}];
  assign next_state_s2[10] = eq_CERAMIDE[{actual_state_s2[48],actual_state_s2[47]}];
  assign next_state_s1[11] = eq_CFLIP[{actual_state_s1[32]}];
  assign next_state_s2[11] = eq_CFLIP[{actual_state_s2[32]}];
  assign next_state_s1[12] = eq_COX2[{actual_state_s1[53],actual_state_s1[43]}];
  assign next_state_s2[12] = eq_COX2[{actual_state_s2[53],actual_state_s2[43]}];
  assign next_state_s1[13] = eq_CYCLIND1[{actual_state_s1[49],actual_state_s1[27],actual_state_s1[21],actual_state_s1[5]}];
  assign next_state_s2[13] = eq_CYCLIND1[{actual_state_s2[49],actual_state_s2[27],actual_state_s2[21],actual_state_s2[5]}];
  assign next_state_s1[14] = eq_CYTC[{actual_state_s1[31]}];
  assign next_state_s2[14] = eq_CYTC[{actual_state_s2[31]}];
  assign next_state_s1[15] = eq_EP2[{actual_state_s1[35]}];
  assign next_state_s2[15] = eq_EP2[{actual_state_s2[35]}];
  assign next_state_s1[16] = eq_ERK[{actual_state_s1[29]}];
  assign next_state_s2[16] = eq_ERK[{actual_state_s2[29]}];
  assign next_state_s1[17] = eq_FAS[{actual_state_s1[65]}];
  assign next_state_s2[17] = eq_FAS[{actual_state_s2[65]}];
  assign next_state_s1[18] = eq_FADD[{actual_state_s1[53],actual_state_s1[17]}];
  assign next_state_s2[18] = eq_FADD[{actual_state_s2[53],actual_state_s2[17]}];
  assign next_state_s1[19] = eq_FOS[{actual_state_s1[16]}];
  assign next_state_s2[19] = eq_FOS[{actual_state_s2[16]}];
  assign next_state_s1[20] = eq_GP130[{actual_state_s1[60]}];
  assign next_state_s2[20] = eq_GP130[{actual_state_s2[60]}];
  assign next_state_s1[21] = eq_GSK3B[{actual_state_s1[15],actual_state_s1[2]}];
  assign next_state_s2[21] = eq_GSK3B[{actual_state_s2[15],actual_state_s2[2]}];
  assign next_state_s1[22] = eq_IAP[{actual_state_s1[49],actual_state_s1[44],actual_state_s1[32]}];
  assign next_state_s2[22] = eq_IAP[{actual_state_s2[49],actual_state_s2[44],actual_state_s2[32]}];
  assign next_state_s1[23] = eq_IKB[{actual_state_s1[24]}];
  assign next_state_s2[23] = eq_IKB[{actual_state_s2[24]}];
  assign next_state_s1[24] = eq_IKK[{actual_state_s1[53],actual_state_s1[43],actual_state_s1[2]}];
  assign next_state_s2[24] = eq_IKK[{actual_state_s2[53],actual_state_s2[43],actual_state_s2[2]}];
  assign next_state_s1[25] = eq_JAK[{actual_state_s1[50],actual_state_s1[20]}];
  assign next_state_s2[25] = eq_JAK[{actual_state_s2[50],actual_state_s2[20]}];
  assign next_state_s1[26] = eq_JNK[{actual_state_s1[30],actual_state_s1[1]}];
  assign next_state_s2[26] = eq_JNK[{actual_state_s2[30],actual_state_s2[1]}];
  assign next_state_s1[27] = eq_JUN[{actual_state_s1[26],actual_state_s1[21],actual_state_s1[16],actual_state_s1[5]}];
  assign next_state_s2[27] = eq_JUN[{actual_state_s2[26],actual_state_s2[21],actual_state_s2[16],actual_state_s2[5]}];
  assign next_state_s1[28] = eq_MDM2[{actual_state_s1[34],actual_state_s1[21],actual_state_s1[2],actual_state_s1[0]}];
  assign next_state_s2[28] = eq_MDM2[{actual_state_s2[34],actual_state_s2[21],actual_state_s2[2],actual_state_s2[0]}];
  assign next_state_s1[29] = eq_MEK[{actual_state_s1[41],actual_state_s1[39]}];
  assign next_state_s2[29] = eq_MEK[{actual_state_s2[41],actual_state_s2[39]}];
  assign next_state_s1[30] = eq_MEKK1[{actual_state_s1[53],actual_state_s1[52],actual_state_s1[10]}];
  assign next_state_s2[30] = eq_MEKK1[{actual_state_s2[53],actual_state_s2[52],actual_state_s2[10]}];
  assign next_state_s1[31] = eq_MOMP[{actual_state_s1[51],actual_state_s1[10],actual_state_s1[6],actual_state_s1[3]}];
  assign next_state_s2[31] = eq_MOMP[{actual_state_s2[51],actual_state_s2[10],actual_state_s2[6],actual_state_s2[3]}];
  assign next_state_s1[32] = eq_NFKB[{actual_state_s1[23]}];
  assign next_state_s2[32] = eq_NFKB[{actual_state_s2[23]}];
  assign next_state_s1[33] = eq_P21[{actual_state_s1[45],actual_state_s1[34],actual_state_s1[21],actual_state_s1[7]}];
  assign next_state_s2[33] = eq_P21[{actual_state_s2[45],actual_state_s2[34],actual_state_s2[21],actual_state_s2[7]}];
  assign next_state_s1[34] = eq_P53[{actual_state_s1[38],actual_state_s1[28],actual_state_s1[26],actual_state_s1[0]}];
  assign next_state_s2[34] = eq_P53[{actual_state_s2[38],actual_state_s2[28],actual_state_s2[26],actual_state_s2[0]}];
  assign next_state_s1[35] = eq_PGE2[{actual_state_s1[12]}];
  assign next_state_s2[35] = eq_PGE2[{actual_state_s2[12]}];
  assign next_state_s1[36] = eq_PI3K[{actual_state_s1[40],actual_state_s1[38],actual_state_s1[15]}];
  assign next_state_s2[36] = eq_PI3K[{actual_state_s2[40],actual_state_s2[38],actual_state_s2[15]}];
  assign next_state_s1[37] = eq_PP2A[{actual_state_s1[10],actual_state_s1[2]}];
  assign next_state_s2[37] = eq_PP2A[{actual_state_s2[10],actual_state_s2[2]}];
  assign next_state_s1[38] = eq_PTEN[{actual_state_s1[34],actual_state_s1[32],actual_state_s1[27]}];
  assign next_state_s2[38] = eq_PTEN[{actual_state_s2[34],actual_state_s2[32],actual_state_s2[27]}];
  assign next_state_s1[39] = eq_RAF[{actual_state_s1[40],actual_state_s1[10]}];
  assign next_state_s2[39] = eq_RAF[{actual_state_s2[40],actual_state_s2[10]}];
  assign next_state_s1[40] = eq_RAS[{actual_state_s1[20],actual_state_s1[15]}];
  assign next_state_s2[40] = eq_RAS[{actual_state_s2[20],actual_state_s2[15]}];
  assign next_state_s1[41] = eq_ROS[{actual_state_s1[53],actual_state_s1[42]}];
  assign next_state_s2[41] = eq_ROS[{actual_state_s2[53],actual_state_s2[42]}];
  assign next_state_s1[42] = eq_SOD[{actual_state_s1[49],actual_state_s1[32]}];
  assign next_state_s2[42] = eq_SOD[{actual_state_s2[49],actual_state_s2[32]}];
  assign next_state_s1[43] = eq_S1P[{actual_state_s1[48]}];
  assign next_state_s2[43] = eq_S1P[{actual_state_s2[48]}];
  assign next_state_s1[44] = eq_SMAC[{actual_state_s1[31]}];
  assign next_state_s2[44] = eq_SMAC[{actual_state_s2[31]}];
  assign next_state_s1[45] = eq_SMAD[{actual_state_s1[52],actual_state_s1[27]}];
  assign next_state_s2[45] = eq_SMAD[{actual_state_s2[52],actual_state_s2[27]}];
  assign next_state_s1[46] = eq_SMAD7[{actual_state_s1[45],actual_state_s1[32]}];
  assign next_state_s2[46] = eq_SMAD7[{actual_state_s2[45],actual_state_s2[32]}];
  assign next_state_s1[47] = eq_SMASE[{actual_state_s1[34],actual_state_s1[18]}];
  assign next_state_s2[47] = eq_SMASE[{actual_state_s2[34],actual_state_s2[18]}];
  assign next_state_s1[48] = eq_SPHK1[{actual_state_s1[53],actual_state_s1[16]}];
  assign next_state_s2[48] = eq_SPHK1[{actual_state_s2[53],actual_state_s2[16]}];
  assign next_state_s1[49] = eq_STAT3[{actual_state_s1[25]}];
  assign next_state_s2[49] = eq_STAT3[{actual_state_s2[25]}];
  assign next_state_s1[50] = eq_SOCS[{actual_state_s1[49]}];
  assign next_state_s2[50] = eq_SOCS[{actual_state_s2[49]}];
  assign next_state_s1[51] = eq_TBID[{actual_state_s1[8],actual_state_s1[6]}];
  assign next_state_s2[51] = eq_TBID[{actual_state_s2[8],actual_state_s2[6]}];
  assign next_state_s1[52] = eq_TGFR[{actual_state_s1[58],actual_state_s1[46]}];
  assign next_state_s2[52] = eq_TGFR[{actual_state_s2[58],actual_state_s2[46]}];
  assign next_state_s1[53] = eq_TNFR[{actual_state_s1[55]}];
  assign next_state_s2[53] = eq_TNFR[{actual_state_s2[55]}];
  assign next_state_s1[54] = eq_TREG[{actual_state_s1[66],actual_state_s1[63],actual_state_s1[60]}];
  assign next_state_s2[54] = eq_TREG[{actual_state_s2[66],actual_state_s2[63],actual_state_s2[60]}];
  assign next_state_s1[55] = eq_TNFA[{actual_state_s1[59]}];
  assign next_state_s2[55] = eq_TNFA[{actual_state_s2[59]}];
  assign next_state_s1[56] = eq_TH2[{actual_state_s1[64],actual_state_s1[61],actual_state_s1[58]}];
  assign next_state_s2[56] = eq_TH2[{actual_state_s2[64],actual_state_s2[61],actual_state_s2[58]}];
  assign next_state_s1[57] = eq_TH1[{actual_state_s1[64],actual_state_s1[63],actual_state_s1[62],actual_state_s1[61],actual_state_s1[58]}];
  assign next_state_s2[57] = eq_TH1[{actual_state_s2[64],actual_state_s2[63],actual_state_s2[62],actual_state_s2[61],actual_state_s2[58]}];
  assign next_state_s1[58] = eq_TGFB[{actual_state_s1[54]}];
  assign next_state_s2[58] = eq_TGFB[{actual_state_s2[54]}];
  assign next_state_s1[59] = eq_MAC[{actual_state_s1[67],actual_state_s1[64],actual_state_s1[63]}];
  assign next_state_s2[59] = eq_MAC[{actual_state_s2[67],actual_state_s2[64],actual_state_s2[63]}];
  assign next_state_s1[60] = eq_IL6[{actual_state_s1[66],actual_state_s1[59],actual_state_s1[32]}];
  assign next_state_s2[60] = eq_IL6[{actual_state_s2[66],actual_state_s2[59],actual_state_s2[32]}];
  assign next_state_s1[61] = eq_IL4[{actual_state_s1[66],actual_state_s1[56]}];
  assign next_state_s2[61] = eq_IL4[{actual_state_s2[66],actual_state_s2[56]}];
  assign next_state_s1[62] = eq_IL12[{actual_state_s1[66],actual_state_s1[59]}];
  assign next_state_s2[62] = eq_IL12[{actual_state_s2[66],actual_state_s2[59]}];
  assign next_state_s1[63] = eq_IL10[{actual_state_s1[56],actual_state_s1[54]}];
  assign next_state_s2[63] = eq_IL10[{actual_state_s2[56],actual_state_s2[54]}];
  assign next_state_s1[64] = eq_IFNG[{actual_state_s1[65],actual_state_s1[57]}];
  assign next_state_s2[64] = eq_IFNG[{actual_state_s2[65],actual_state_s2[57]}];
  assign next_state_s1[65] = eq_CTL[{actual_state_s1[64],actual_state_s1[58]}];
  assign next_state_s2[65] = eq_CTL[{actual_state_s2[64],actual_state_s2[58]}];
  assign next_state_s1[66] = eq_DC[{actual_state_s1[67],actual_state_s1[63],actual_state_s1[55]}];
  assign next_state_s2[66] = eq_DC[{actual_state_s2[67],actual_state_s2[63],actual_state_s2[55]}];
  assign next_state_s1[67] = eq_CCL2[{actual_state_s1[32]}];
  assign next_state_s2[67] = eq_CCL2[{actual_state_s2[32]}];
  assign next_state_s1[68] = eq_Proliferation[{actual_state_s1[33],actual_state_s1[19],actual_state_s1[13],actual_state_s1[7]}];
  assign next_state_s2[68] = eq_Proliferation[{actual_state_s2[33],actual_state_s2[19],actual_state_s2[13],actual_state_s2[7]}];
  assign next_state_s1[69] = eq_Apoptosis[{actual_state_s1[7]}];
  assign next_state_s2[69] = eq_Apoptosis[{actual_state_s2[7]}];

  //Output data fifo instantiation
  assign output_available = ~fifo_empty;

  fifo
  #(
    .FIFO_WIDTH(32),
    .FIFO_DEPTH_BITS(6)
  )
  grn_mem_core_output_fifo
  (
    .clk(clk),
    .rst(rst),
    .write_enable(fifo_write_enable),
    .input_data(fifo_input_data),
    .output_read_enable(output_read_enable),
    .output_valid(output_valid),
    .output_data(output_data),
    .empty(fifo_empty),
    .almostfull(fifo_full)
  );


  initial begin
    fifo_write_enable = 0;
    fifo_input_data = 0;
    actual_state_s1 = 0;
    actual_state_s2 = 0;
    exec_state = 0;
    flag_pulse = 0;
    flag_first_it = 0;
    transient_counter = 0;
    period_counter = 0;
    data_to_write = 0;
    write_counter = 0;
    fsm_mem = 0;
  end


endmodule



module fifo #
(
  parameter FIFO_WIDTH = 32,
  parameter FIFO_DEPTH_BITS = 8,
  parameter FIFO_ALMOSTFULL_THRESHOLD = 2 ** FIFO_DEPTH_BITS - 4,
  parameter FIFO_ALMOSTEMPTY_THRESHOLD = 2
)
(
  input clk,
  input rst,
  input write_enable,
  input [FIFO_WIDTH-1:0] input_data,
  input output_read_enable,
  output reg output_valid,
  output reg [FIFO_WIDTH-1:0] output_data,
  output reg empty,
  output reg almostempty,
  output reg full,
  output reg almostfull,
  output reg [FIFO_DEPTH_BITS+1-1:0] data_count
);

  reg [FIFO_DEPTH_BITS-1:0] read_pointer;
  reg [FIFO_DEPTH_BITS-1:0] write_pointer;
  (* ramstyle = "AUTO, no_rw_check" *) reg  [FIFO_WIDTH-1:0] mem[0:2**FIFO_DEPTH_BITS-1];
  /*
  reg [FIFO_WIDTH-1:0] mem [0:2**FIFO_DEPTH_BITS-1];
  */

  always @(posedge clk) begin
    if(rst) begin
      empty <= 1;
      almostempty <= 1;
      full <= 0;
      almostfull <= 0;
      read_pointer <= 0;
      write_pointer <= 0;
      data_count <= 0;
    end else begin
      case({ write_enable, output_read_enable })
        3: begin
          read_pointer <= read_pointer + 1;
          write_pointer <= write_pointer + 1;
        end
        2: begin
          if(~full) begin
            write_pointer <= write_pointer + 1;
            data_count <= data_count + 1;
            empty <= 0;
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD - 1) begin
              almostempty <= 0;
            end 
            if(data_count == 2 ** FIFO_DEPTH_BITS - 1) begin
              full <= 1;
            end 
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD - 1) begin
              almostfull <= 1;
            end 
          end 
        end
        1: begin
          if(~empty) begin
            read_pointer <= read_pointer + 1;
            data_count <= data_count - 1;
            full <= 0;
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD) begin
              almostfull <= 0;
            end 
            if(data_count == 1) begin
              empty <= 1;
            end 
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD) begin
              almostempty <= 1;
            end 
          end 
        end
      endcase
    end
  end


  always @(posedge clk) begin
    if(rst) begin
      output_valid <= 0;
    end else begin
      output_valid <= 0;
      if(write_enable == 1) begin
        mem[write_pointer] <= input_data;
      end 
      if(output_read_enable == 1) begin
        output_data <= mem[read_pointer];
        output_valid <= 1;
      end 
    end
  end


endmodule

