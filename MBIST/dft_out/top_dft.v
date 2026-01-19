/////////////////////////////////////////////////////////////
// Created by: Synopsys Design Compiler(R)
// Version   : R-2020.09-SP5
// Date      : Mon Jan 19 14:52:57 2026
/////////////////////////////////////////////////////////////


module bist_buf_pDATA_WIDTH2_test_1 ( bist_clk, bist_rst_n, bist_cs, bist_we, 
        bist_pat, buf_cs, buf_we, buf_pat, test_si, test_se );
  input [1:0] bist_pat;
  output [1:0] buf_pat;
  input bist_clk, bist_rst_n, bist_cs, bist_we, test_si, test_se;
  output buf_cs, buf_we;


  SDFFRHQXL cs_buf_1_reg ( .D(bist_cs), .SI(test_si), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(buf_cs) );
  SDFFRHQXL we_buf_1_reg ( .D(bist_we), .SI(buf_pat[1]), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(buf_we) );
  SDFFRHQXL pat_buf_1_reg_1_ ( .D(bist_pat[1]), .SI(buf_pat[0]), .SE(test_se), 
        .CK(bist_clk), .RN(bist_rst_n), .Q(buf_pat[1]) );
  SDFFRHQXL pat_buf_1_reg_0_ ( .D(bist_pat[0]), .SI(buf_cs), .SE(test_se), 
        .CK(bist_clk), .RN(bist_rst_n), .Q(buf_pat[0]) );
endmodule


module bist_cmp_pDATA_WIDTH2_test_1 ( bist_clk, bist_rst_n, bist_cs, bist_we, 
        bist_pat, bist_resp, pass_or_fail, test_se );
  input [1:0] bist_pat;
  input [1:0] bist_resp;
  input bist_clk, bist_rst_n, bist_cs, bist_we, test_se;
  output pass_or_fail;
  wire   N6, n5, n60, n7;

  NAND2X1 U3 ( .A(n5), .B(bist_cs), .Y(N6) );
  AOI21X1 U4 ( .A0(n60), .A1(n7), .B0(bist_we), .Y(n5) );
  XNOR2X1 U5 ( .A(bist_resp[1]), .B(bist_pat[1]), .Y(n60) );
  XNOR2X1 U6 ( .A(bist_resp[0]), .B(bist_pat[0]), .Y(n7) );
  SDFFSXL pass_or_fail_reg_reg ( .D(N6), .SI(bist_we), .SE(test_se), .CK(
        bist_clk), .SN(bist_rst_n), .Q(pass_or_fail) );
endmodule


module bist_controller_test_1 ( bist_clk, bist_rst_n, bist_start, 
        max_addr_done, min_addr_done, addr_clr_en, addr_up_en, addr_dn_en, 
        pat_sel, bist_cs, bist_we, bist_done, test_si, test_so, test_se );
  input bist_clk, bist_rst_n, bist_start, max_addr_done, min_addr_done,
         test_si, test_se;
  output addr_clr_en, addr_up_en, addr_dn_en, pat_sel, bist_cs, bist_we,
         bist_done, test_so;
  wire   bist_cs_tmp, bist_we_tmp, n1, n3, n4, n5, n6, n7, n8, n9, n10, n11,
         n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25,
         n26, n27, n28;
  wire   [2:0] state;
  wire   [2:0] nxt_state;
  assign test_so = state[2];

  INVX1 U3 ( .A(n16), .Y(n1) );
  INVX1 U4 ( .A(max_addr_done), .Y(n9) );
  INVX1 U5 ( .A(min_addr_done), .Y(n10) );
  INVX1 U6 ( .A(n24), .Y(n4) );
  INVX1 U7 ( .A(n25), .Y(n13) );
  NOR2X1 U8 ( .A(n7), .B(n5), .Y(n24) );
  NOR2X1 U9 ( .A(n8), .B(n3), .Y(n15) );
  NAND2X1 U10 ( .A(n24), .B(n3), .Y(n12) );
  OAI21XL U11 ( .A0(n14), .A1(n13), .B0(n11), .Y(nxt_state[2]) );
  AOI2BB1X1 U12 ( .A0N(n9), .A1N(n12), .B0(n15), .Y(n14) );
  AOI21X1 U13 ( .A0(n11), .A1(n12), .B0(n13), .Y(pat_sel) );
  NAND3X1 U14 ( .A(n12), .B(n11), .C(n25), .Y(bist_cs_tmp) );
  NOR3X1 U15 ( .A(n13), .B(n4), .C(n3), .Y(n28) );
  NOR3X1 U16 ( .A(n13), .B(state[2]), .C(n24), .Y(addr_clr_en) );
  NOR2X1 U17 ( .A(n7), .B(state[1]), .Y(n17) );
  AOI21X1 U18 ( .A0(n7), .A1(state[1]), .B0(n17), .Y(n25) );
  NOR2X1 U19 ( .A(n26), .B(state[2]), .Y(addr_up_en) );
  OAI21XL U20 ( .A0(n5), .A1(n9), .B0(state[0]), .Y(n26) );
  INVX1 U21 ( .A(state[0]), .Y(n7) );
  INVX1 U22 ( .A(state[1]), .Y(n5) );
  OAI22X1 U23 ( .A0(n6), .A1(n3), .B0(n27), .B1(n3), .Y(addr_dn_en) );
  INVX1 U24 ( .A(n17), .Y(n6) );
  NAND3X1 U25 ( .A(n10), .B(n7), .C(state[1]), .Y(n27) );
  AOI2BB2X1 U26 ( .B0(n17), .B1(n18), .A0N(n5), .A1N(n19), .Y(n16) );
  OAI22X1 U27 ( .A0(n3), .A1(n10), .B0(state[2]), .B1(n9), .Y(n18) );
  AOI211X1 U28 ( .A0(n3), .A1(n9), .B0(n15), .C0(n7), .Y(n19) );
  INVX1 U29 ( .A(state[2]), .Y(n3) );
  NAND2X1 U30 ( .A(n20), .B(n21), .Y(nxt_state[0]) );
  OAI21XL U31 ( .A0(n22), .A1(n23), .B0(n7), .Y(n21) );
  AOI32X1 U32 ( .A0(n9), .A1(n3), .A2(n17), .B0(n15), .B1(n24), .Y(n20) );
  AOI21X1 U33 ( .A0(n3), .A1(n8), .B0(state[1]), .Y(n22) );
  NAND2X1 U34 ( .A(state[2]), .B(n4), .Y(n11) );
  AOI21X1 U35 ( .A0(state[2]), .A1(n10), .B0(n5), .Y(n23) );
  OAI22X1 U36 ( .A0(state[2]), .A1(n7), .B0(state[1]), .B1(n7), .Y(bist_we_tmp) );
  INVX1 U37 ( .A(bist_start), .Y(n8) );
  SDFFRHQXL state_reg_2_ ( .D(nxt_state[2]), .SI(state[1]), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(state[2]) );
  SDFFRHQXL state_reg_0_ ( .D(nxt_state[0]), .SI(bist_we), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(state[0]) );
  SDFFRHQXL state_reg_1_ ( .D(n1), .SI(state[0]), .SE(test_se), .CK(bist_clk), 
        .RN(bist_rst_n), .Q(state[1]) );
  SDFFRHQXL bist_we_reg_reg ( .D(bist_we_tmp), .SI(bist_done), .SE(test_se), 
        .CK(bist_clk), .RN(bist_rst_n), .Q(bist_we) );
  SDFFRHQXL bist_done_reg_reg ( .D(n28), .SI(bist_cs), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(bist_done) );
  SDFFRHQXL bist_cs_reg_reg ( .D(bist_cs_tmp), .SI(test_si), .SE(test_se), 
        .CK(bist_clk), .RN(bist_rst_n), .Q(bist_cs) );
endmodule


module bist_pat_gen_pDATA_WIDTH2_test_1 ( bist_clk, bist_rst_n, pat_sel, 
        bist_pat, test_si, test_se );
  output [1:0] bist_pat;
  input bist_clk, bist_rst_n, pat_sel, test_si, test_se;


  SDFFRHQXL bist_pat_reg_reg_1_ ( .D(pat_sel), .SI(bist_pat[0]), .SE(test_se), 
        .CK(bist_clk), .RN(bist_rst_n), .Q(bist_pat[1]) );
  SDFFRHQXL bist_pat_reg_reg_0_ ( .D(pat_sel), .SI(test_si), .SE(test_se), 
        .CK(bist_clk), .RN(bist_rst_n), .Q(bist_pat[0]) );
endmodule


module bist_addr_gen_pADDR_WIDTH4_test_1 ( bist_clk, bist_rst_n, addr_clr_en, 
        addr_up_en, addr_dn_en, bist_addr, max_addr_done, min_addr_done, 
        test_si, test_se );
  output [3:0] bist_addr;
  input bist_clk, bist_rst_n, addr_clr_en, addr_up_en, addr_dn_en, test_si,
         test_se;
  output max_addr_done, min_addr_done;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27;
  wire   [3:0] addr_cnt;

  INVX1 U3 ( .A(n14), .Y(n2) );
  INVX1 U4 ( .A(n13), .Y(n8) );
  INVX1 U5 ( .A(n12), .Y(min_addr_done) );
  NOR3BX1 U6 ( .AN(addr_up_en), .B(max_addr_done), .C(addr_clr_en), .Y(n14) );
  NOR2X1 U7 ( .A(addr_clr_en), .B(addr_up_en), .Y(n13) );
  NOR2X1 U8 ( .A(n11), .B(n3), .Y(max_addr_done) );
  INVX1 U9 ( .A(n16), .Y(n7) );
  OAI21XL U10 ( .A0(n7), .A1(n6), .B0(n23), .Y(n27) );
  OAI211X1 U11 ( .A0(n14), .A1(n13), .B0(n7), .C0(n6), .Y(n23) );
  NAND4X1 U12 ( .A(n6), .B(n5), .C(n4), .D(n3), .Y(n12) );
  OAI2BB2X1 U13 ( .B0(n7), .B1(n3), .A0N(n7), .A1N(n9), .Y(n24) );
  OAI222XL U14 ( .A0(n10), .A1(n3), .B0(n11), .B1(n2), .C0(n8), .C1(n12), .Y(
        n9) );
  AOI211X1 U15 ( .A0(addr_cnt[2]), .A1(n13), .B0(n1), .C0(n14), .Y(n10) );
  OAI22X1 U16 ( .A0(n8), .A1(n6), .B0(addr_cnt[0]), .B1(n2), .Y(n20) );
  INVX1 U17 ( .A(n18), .Y(n1) );
  AOI211X1 U18 ( .A0(n13), .A1(addr_cnt[1]), .B0(n19), .C0(n20), .Y(n18) );
  NAND3X1 U19 ( .A(addr_cnt[1]), .B(addr_cnt[0]), .C(addr_cnt[2]), .Y(n11) );
  NOR2X1 U20 ( .A(n2), .B(addr_cnt[1]), .Y(n19) );
  INVX1 U21 ( .A(addr_cnt[3]), .Y(n3) );
  OAI32X1 U22 ( .A0(n15), .A1(addr_cnt[2]), .A2(n16), .B0(n17), .B1(n4), .Y(
        n25) );
  AOI31X1 U23 ( .A0(addr_cnt[1]), .A1(addr_cnt[0]), .A2(n14), .B0(n21), .Y(n15) );
  NOR2X1 U24 ( .A(n16), .B(n1), .Y(n17) );
  OAI22X1 U25 ( .A0(n7), .A1(n5), .B0(n16), .B1(n22), .Y(n26) );
  AOI221X1 U26 ( .A0(addr_cnt[1]), .A1(n20), .B0(n19), .B1(addr_cnt[0]), .C0(
        n21), .Y(n22) );
  NOR3X1 U27 ( .A(addr_cnt[0]), .B(addr_cnt[1]), .C(n8), .Y(n21) );
  NOR2X1 U28 ( .A(addr_dn_en), .B(n8), .Y(n16) );
  INVX1 U29 ( .A(addr_cnt[0]), .Y(n6) );
  INVX1 U30 ( .A(addr_cnt[1]), .Y(n5) );
  INVX1 U31 ( .A(addr_cnt[2]), .Y(n4) );
  SDFFRHQXL addr_cnt_reg_3_ ( .D(n24), .SI(addr_cnt[2]), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(addr_cnt[3]) );
  SDFFRHQXL addr_cnt_reg_2_ ( .D(n25), .SI(addr_cnt[1]), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(addr_cnt[2]) );
  SDFFRHQXL addr_cnt_reg_0_ ( .D(n27), .SI(test_si), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(addr_cnt[0]) );
  SDFFRHQXL addr_cnt_reg_1_ ( .D(n26), .SI(addr_cnt[0]), .SE(test_se), .CK(
        bist_clk), .RN(bist_rst_n), .Q(addr_cnt[1]) );
  SDFFRHQXL bist_addr_reg_reg_3_ ( .D(addr_cnt[3]), .SI(bist_addr[2]), .SE(
        test_se), .CK(bist_clk), .RN(bist_rst_n), .Q(bist_addr[3]) );
  SDFFRHQXL bist_addr_reg_reg_2_ ( .D(addr_cnt[2]), .SI(bist_addr[1]), .SE(
        test_se), .CK(bist_clk), .RN(bist_rst_n), .Q(bist_addr[2]) );
  SDFFRHQXL bist_addr_reg_reg_1_ ( .D(addr_cnt[1]), .SI(bist_addr[0]), .SE(
        test_se), .CK(bist_clk), .RN(bist_rst_n), .Q(bist_addr[1]) );
  SDFFRHQXL bist_addr_reg_reg_0_ ( .D(addr_cnt[0]), .SI(addr_cnt[3]), .SE(
        test_se), .CK(bist_clk), .RN(bist_rst_n), .Q(bist_addr[0]) );
endmodule


module top ( clk, rst_n, bist_start, bist_resp, bist_cs, bist_we, bist_addr, 
        bist_pat, bist_done, pass_or_fail, test_si, test_se );
  input [1:0] bist_resp;
  output [3:0] bist_addr;
  output [1:0] bist_pat;
  input clk, rst_n, bist_start, test_si, test_se;
  output bist_cs, bist_we, bist_done, pass_or_fail;
  wire   addr_clr_en, addr_up_en, addr_dn_en, max_addr_done, min_addr_done,
         pat_sel, buf_cs, buf_we, n2;
  wire   [1:0] buf_pat;

  bist_controller_test_1 i_bist_controller ( .bist_clk(clk), .bist_rst_n(rst_n), .bist_start(bist_start), .max_addr_done(max_addr_done), .min_addr_done(
        min_addr_done), .addr_clr_en(addr_clr_en), .addr_up_en(addr_up_en), 
        .addr_dn_en(addr_dn_en), .pat_sel(pat_sel), .bist_cs(bist_cs), 
        .bist_we(bist_we), .bist_done(bist_done), .test_si(pass_or_fail), 
        .test_so(n2), .test_se(test_se) );
  bist_addr_gen_pADDR_WIDTH4_test_1 i_bist_addr_gen ( .bist_clk(clk), 
        .bist_rst_n(rst_n), .addr_clr_en(addr_clr_en), .addr_up_en(addr_up_en), 
        .addr_dn_en(addr_dn_en), .bist_addr(bist_addr), .max_addr_done(
        max_addr_done), .min_addr_done(min_addr_done), .test_si(test_si), 
        .test_se(test_se) );
  bist_pat_gen_pDATA_WIDTH2_test_1 i_bist_pat_gen ( .bist_clk(clk), 
        .bist_rst_n(rst_n), .pat_sel(pat_sel), .bist_pat(bist_pat), .test_si(
        n2), .test_se(test_se) );
  bist_buf_pDATA_WIDTH2_test_1 i_bist_buf ( .bist_clk(clk), .bist_rst_n(rst_n), 
        .bist_cs(bist_cs), .bist_we(bist_we), .bist_pat(bist_pat), .buf_cs(
        buf_cs), .buf_we(buf_we), .buf_pat(buf_pat), .test_si(bist_addr[3]), 
        .test_se(test_se) );
  bist_cmp_pDATA_WIDTH2_test_1 i_bist_cmp ( .bist_clk(clk), .bist_rst_n(rst_n), 
        .bist_cs(buf_cs), .bist_we(buf_we), .bist_pat(buf_pat), .bist_resp(
        bist_resp), .pass_or_fail(pass_or_fail), .test_se(test_se) );
endmodule

