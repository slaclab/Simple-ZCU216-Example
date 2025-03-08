-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RfDataConverter Module
-------------------------------------------------------------------------------
-- This file is part of 'Simple-ZCU216-Example'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'Simple-ZCU216-Example', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.SsiPkg.all;

library work;
use work.AppPkg.all;

library axi_soc_ultra_plus_core;
use axi_soc_ultra_plus_core.AxiSocUltraPlusPkg.all;

library unisim;
use unisim.vcomponents.all;

entity RfDataConverter is
   generic (
      TPD_G            : time := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- RF DATA CONVERTER Ports
      adcClkP         : in  sl;
      adcClkN         : in  sl;
      adcP            : in  slv(15 downto 0);
      adcN            : in  slv(15 downto 0);
      dacClkP         : in  sl;
      dacClkN         : in  sl;
      dacP            : out slv(15 downto 0);
      dacN            : out slv(15 downto 0);
      sysRefP         : in  sl;
      sysRefN         : in  sl;
      plClkP          : in  sl;
      plClkN          : in  sl;
      plSysRefP       : in  sl;
      plSysRefN       : in  sl;
      -- ADC/DAC Interface (dspClk domain)
      dspClk          : out sl;
      dspRst          : out sl;
      dspAdc          : out Slv256Array(15 downto 0);
      dspDac          : in  Slv256Array(15 downto 0);
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType);
end RfDataConverter;

architecture mapping of RfDataConverter is

   component RfDataConverterIpCore
      port (
         clk_adc0        : out std_logic;
         clk_adc1        : out std_logic;
         adc2_clk_p      : in  std_logic;
         adc2_clk_n      : in  std_logic;
         clk_adc2        : out std_logic;
         clk_adc3        : out std_logic;
         clk_dac0        : out std_logic;
         clk_dac1        : out std_logic;
         dac2_clk_p      : in  std_logic;
         dac2_clk_n      : in  std_logic;
         clk_dac2        : out std_logic;
         clk_dac3        : out std_logic;
         s_axi_aclk      : in  std_logic;
         s_axi_aresetn   : in  std_logic;
         s_axi_awaddr    : in  std_logic_vector(17 downto 0);
         s_axi_awvalid   : in  std_logic;
         s_axi_awready   : out std_logic;
         s_axi_wdata     : in  std_logic_vector(31 downto 0);
         s_axi_wstrb     : in  std_logic_vector(3 downto 0);
         s_axi_wvalid    : in  std_logic;
         s_axi_wready    : out std_logic;
         s_axi_bresp     : out std_logic_vector(1 downto 0);
         s_axi_bvalid    : out std_logic;
         s_axi_bready    : in  std_logic;
         s_axi_araddr    : in  std_logic_vector(17 downto 0);
         s_axi_arvalid   : in  std_logic;
         s_axi_arready   : out std_logic;
         s_axi_rdata     : out std_logic_vector(31 downto 0);
         s_axi_rresp     : out std_logic_vector(1 downto 0);
         s_axi_rvalid    : out std_logic;
         s_axi_rready    : in  std_logic;
         irq             : out std_logic;
         sysref_in_p     : in  std_logic;
         sysref_in_n     : in  std_logic;
         user_sysref_adc : in  std_logic;
         user_sysref_dac : in  std_logic;
         vin00_p         : in  std_logic;
         vin00_n         : in  std_logic;
         vin01_p         : in  std_logic;
         vin01_n         : in  std_logic;
         vin02_p         : in  std_logic;
         vin02_n         : in  std_logic;
         vin03_p         : in  std_logic;
         vin03_n         : in  std_logic;
         vin10_p         : in  std_logic;
         vin10_n         : in  std_logic;
         vin11_p         : in  std_logic;
         vin11_n         : in  std_logic;
         vin12_p         : in  std_logic;
         vin12_n         : in  std_logic;
         vin13_p         : in  std_logic;
         vin13_n         : in  std_logic;
         vin20_p         : in  std_logic;
         vin20_n         : in  std_logic;
         vin21_p         : in  std_logic;
         vin21_n         : in  std_logic;
         vin22_p         : in  std_logic;
         vin22_n         : in  std_logic;
         vin23_p         : in  std_logic;
         vin23_n         : in  std_logic;
         vin30_p         : in  std_logic;
         vin30_n         : in  std_logic;
         vin31_p         : in  std_logic;
         vin31_n         : in  std_logic;
         vin32_p         : in  std_logic;
         vin32_n         : in  std_logic;
         vin33_p         : in  std_logic;
         vin33_n         : in  std_logic;
         vout00_p        : out std_logic;
         vout00_n        : out std_logic;
         vout01_p        : out std_logic;
         vout01_n        : out std_logic;
         vout02_p        : out std_logic;
         vout02_n        : out std_logic;
         vout03_p        : out std_logic;
         vout03_n        : out std_logic;
         vout10_p        : out std_logic;
         vout10_n        : out std_logic;
         vout11_p        : out std_logic;
         vout11_n        : out std_logic;
         vout12_p        : out std_logic;
         vout12_n        : out std_logic;
         vout13_p        : out std_logic;
         vout13_n        : out std_logic;
         vout20_p        : out std_logic;
         vout20_n        : out std_logic;
         vout21_p        : out std_logic;
         vout21_n        : out std_logic;
         vout22_p        : out std_logic;
         vout22_n        : out std_logic;
         vout23_p        : out std_logic;
         vout23_n        : out std_logic;
         vout30_p        : out std_logic;
         vout30_n        : out std_logic;
         vout31_p        : out std_logic;
         vout31_n        : out std_logic;
         vout32_p        : out std_logic;
         vout32_n        : out std_logic;
         vout33_p        : out std_logic;
         vout33_n        : out std_logic;
         m0_axis_aresetn : in  std_logic;
         m0_axis_aclk    : in  std_logic;
         m00_axis_tdata  : out std_logic_vector(191 downto 0);
         m00_axis_tvalid : out std_logic;
         m00_axis_tready : in  std_logic;
         m01_axis_tdata  : out std_logic_vector(191 downto 0);
         m01_axis_tvalid : out std_logic;
         m01_axis_tready : in  std_logic;
         m02_axis_tdata  : out std_logic_vector(191 downto 0);
         m02_axis_tvalid : out std_logic;
         m02_axis_tready : in  std_logic;
         m03_axis_tdata  : out std_logic_vector(191 downto 0);
         m03_axis_tvalid : out std_logic;
         m03_axis_tready : in  std_logic;
         m1_axis_aresetn : in  std_logic;
         m1_axis_aclk    : in  std_logic;
         m10_axis_tdata  : out std_logic_vector(191 downto 0);
         m10_axis_tvalid : out std_logic;
         m10_axis_tready : in  std_logic;
         m11_axis_tdata  : out std_logic_vector(191 downto 0);
         m11_axis_tvalid : out std_logic;
         m11_axis_tready : in  std_logic;
         m12_axis_tdata  : out std_logic_vector(191 downto 0);
         m12_axis_tvalid : out std_logic;
         m12_axis_tready : in  std_logic;
         m13_axis_tdata  : out std_logic_vector(191 downto 0);
         m13_axis_tvalid : out std_logic;
         m13_axis_tready : in  std_logic;
         m2_axis_aresetn : in  std_logic;
         m2_axis_aclk    : in  std_logic;
         m20_axis_tdata  : out std_logic_vector(191 downto 0);
         m20_axis_tvalid : out std_logic;
         m20_axis_tready : in  std_logic;
         m21_axis_tdata  : out std_logic_vector(191 downto 0);
         m21_axis_tvalid : out std_logic;
         m21_axis_tready : in  std_logic;
         m22_axis_tdata  : out std_logic_vector(191 downto 0);
         m22_axis_tvalid : out std_logic;
         m22_axis_tready : in  std_logic;
         m23_axis_tdata  : out std_logic_vector(191 downto 0);
         m23_axis_tvalid : out std_logic;
         m23_axis_tready : in  std_logic;
         m3_axis_aresetn : in  std_logic;
         m3_axis_aclk    : in  std_logic;
         m30_axis_tdata  : out std_logic_vector(191 downto 0);
         m30_axis_tvalid : out std_logic;
         m30_axis_tready : in  std_logic;
         m31_axis_tdata  : out std_logic_vector(191 downto 0);
         m31_axis_tvalid : out std_logic;
         m31_axis_tready : in  std_logic;
         m32_axis_tdata  : out std_logic_vector(191 downto 0);
         m32_axis_tvalid : out std_logic;
         m32_axis_tready : in  std_logic;
         m33_axis_tdata  : out std_logic_vector(191 downto 0);
         m33_axis_tvalid : out std_logic;
         m33_axis_tready : in  std_logic;
         s0_axis_aresetn : in  std_logic;
         s0_axis_aclk    : in  std_logic;
         s00_axis_tdata  : in  std_logic_vector(255 downto 0);
         s00_axis_tvalid : in  std_logic;
         s00_axis_tready : out std_logic;
         s01_axis_tdata  : in  std_logic_vector(255 downto 0);
         s01_axis_tvalid : in  std_logic;
         s01_axis_tready : out std_logic;
         s02_axis_tdata  : in  std_logic_vector(255 downto 0);
         s02_axis_tvalid : in  std_logic;
         s02_axis_tready : out std_logic;
         s03_axis_tdata  : in  std_logic_vector(255 downto 0);
         s03_axis_tvalid : in  std_logic;
         s03_axis_tready : out std_logic;
         s1_axis_aresetn : in  std_logic;
         s1_axis_aclk    : in  std_logic;
         s10_axis_tdata  : in  std_logic_vector(255 downto 0);
         s10_axis_tvalid : in  std_logic;
         s10_axis_tready : out std_logic;
         s11_axis_tdata  : in  std_logic_vector(255 downto 0);
         s11_axis_tvalid : in  std_logic;
         s11_axis_tready : out std_logic;
         s12_axis_tdata  : in  std_logic_vector(255 downto 0);
         s12_axis_tvalid : in  std_logic;
         s12_axis_tready : out std_logic;
         s13_axis_tdata  : in  std_logic_vector(255 downto 0);
         s13_axis_tvalid : in  std_logic;
         s13_axis_tready : out std_logic;
         s2_axis_aresetn : in  std_logic;
         s2_axis_aclk    : in  std_logic;
         s20_axis_tdata  : in  std_logic_vector(255 downto 0);
         s20_axis_tvalid : in  std_logic;
         s20_axis_tready : out std_logic;
         s21_axis_tdata  : in  std_logic_vector(255 downto 0);
         s21_axis_tvalid : in  std_logic;
         s21_axis_tready : out std_logic;
         s22_axis_tdata  : in  std_logic_vector(255 downto 0);
         s22_axis_tvalid : in  std_logic;
         s22_axis_tready : out std_logic;
         s23_axis_tdata  : in  std_logic_vector(255 downto 0);
         s23_axis_tvalid : in  std_logic;
         s23_axis_tready : out std_logic;
         s3_axis_aresetn : in  std_logic;
         s3_axis_aclk    : in  std_logic;
         s30_axis_tdata  : in  std_logic_vector(255 downto 0);
         s30_axis_tvalid : in  std_logic;
         s30_axis_tready : out std_logic;
         s31_axis_tdata  : in  std_logic_vector(255 downto 0);
         s31_axis_tvalid : in  std_logic;
         s31_axis_tready : out std_logic;
         s32_axis_tdata  : in  std_logic_vector(255 downto 0);
         s32_axis_tvalid : in  std_logic;
         s32_axis_tready : out std_logic;
         s33_axis_tdata  : in  std_logic_vector(255 downto 0);
         s33_axis_tvalid : in  std_logic;
         s33_axis_tready : out std_logic
         );
   end component;

   signal rfdcAdc   : Slv192Array(15 downto 0) := (others => (others => '0'));
   signal rfdcValid : slv(15 downto 0)         := (others => '0');
   signal rfdcDac   : Slv256Array(15 downto 0) := (others => (others => '0'));

   signal adc      : Slv192Array(15 downto 0) := (others => (others => '0'));
   signal adcValid : slv(15 downto 0)         := (others => '0');

   signal refClk   : sl := '0';
   signal axilRstL : sl := '0';

   signal rfdcClk  : sl := '0';
   signal rfdcRst  : sl := '1';
   signal rfdcRstL : sl := '0';

   signal dspClock  : sl := '0';
   signal dspReset  : sl := '1';
   signal dspResetL : sl := '0';

   signal plSysRefRaw : sl := '0';
   signal adcSysRef   : sl := '0';
   signal dacSysRef   : sl := '0';

begin

   U_plSysRefRaw : IBUFDS
      port map (
         I  => plSysRefP,
         IB => plSysRefN,
         O  => plSysRefRaw);

   U_adcSysRef : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => rfdcClk,
         dataIn  => plSysRefRaw,
         dataOut => adcSysRef);

   U_dacSysRef : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => dspClock,
         dataIn  => plSysRefRaw,
         dataOut => dacSysRef);

   U_IpCore : RfDataConverterIpCore
      port map (
         -- Clock Ports
         adc2_clk_p      => adcClkP,
         adc2_clk_n      => adcClkN,
         dac2_clk_p      => dacClkP,
         dac2_clk_n      => dacClkN,
         -- AXI-Lite Ports
         s_axi_aclk      => axilClk,
         s_axi_aresetn   => axilRstL,
         s_axi_awaddr    => axilWriteMaster.awaddr(17 downto 0),
         s_axi_awvalid   => axilWriteMaster.awvalid,
         s_axi_awready   => axilWriteSlave.awready,
         s_axi_wdata     => axilWriteMaster.wdata,
         s_axi_wstrb     => axilWriteMaster.wstrb,
         s_axi_wvalid    => axilWriteMaster.wvalid,
         s_axi_wready    => axilWriteSlave.wready,
         s_axi_bresp     => axilWriteSlave.bresp,
         s_axi_bvalid    => axilWriteSlave.bvalid,
         s_axi_bready    => axilWriteMaster.bready,
         s_axi_araddr    => axilReadMaster.araddr(17 downto 0),
         s_axi_arvalid   => axilReadMaster.arvalid,
         s_axi_arready   => axilReadSlave.arready,
         s_axi_rdata     => axilReadSlave.rdata,
         s_axi_rresp     => axilReadSlave.rresp,
         s_axi_rvalid    => axilReadSlave.rvalid,
         s_axi_rready    => axilReadMaster.rready,
         -- Misc. Ports
         sysref_in_p     => sysRefP,
         sysref_in_n     => sysRefN,
         user_sysref_adc => adcSysRef,
         user_sysref_dac => dacSysRef,
         -- ADC Ports
         vin00_p         => adcP(0),
         vin00_n         => adcN(0),
         vin01_p         => adcP(1),
         vin01_n         => adcN(1),
         vin02_p         => adcP(2),
         vin02_n         => adcN(2),
         vin03_p         => adcP(3),
         vin03_n         => adcN(3),
         vin10_p         => adcP(4),
         vin10_n         => adcN(4),
         vin11_p         => adcP(5),
         vin11_n         => adcN(5),
         vin12_p         => adcP(6),
         vin12_n         => adcN(6),
         vin13_p         => adcP(7),
         vin13_n         => adcN(7),
         vin20_p         => adcP(8),
         vin20_n         => adcN(8),
         vin21_p         => adcP(9),
         vin21_n         => adcN(9),
         vin22_p         => adcP(10),
         vin22_n         => adcN(10),
         vin23_p         => adcP(11),
         vin23_n         => adcN(11),
         vin30_p         => adcP(12),
         vin30_n         => adcN(12),
         vin31_p         => adcP(13),
         vin31_n         => adcN(13),
         vin32_p         => adcP(14),
         vin32_n         => adcN(14),
         vin33_p         => adcP(15),
         vin33_n         => adcN(15),
         -- DAC Ports
         vout00_p        => dacP(0),
         vout00_n        => dacN(0),
         vout01_p        => dacP(1),
         vout01_n        => dacN(1),
         vout02_p        => dacP(2),
         vout02_n        => dacN(2),
         vout03_p        => dacP(3),
         vout03_n        => dacN(3),
         vout10_p        => dacP(4),
         vout10_n        => dacN(4),
         vout11_p        => dacP(5),
         vout11_n        => dacN(5),
         vout12_p        => dacP(6),
         vout12_n        => dacN(6),
         vout13_p        => dacP(7),
         vout13_n        => dacN(7),
         vout20_p        => dacP(8),
         vout20_n        => dacN(8),
         vout21_p        => dacP(9),
         vout21_n        => dacN(9),
         vout22_p        => dacP(10),
         vout22_n        => dacN(10),
         vout23_p        => dacP(11),
         vout23_n        => dacN(11),
         vout30_p        => dacP(12),
         vout30_n        => dacN(12),
         vout31_p        => dacP(13),
         vout31_n        => dacN(13),
         vout32_p        => dacP(14),
         vout32_n        => dacN(14),
         vout33_p        => dacP(15),
         vout33_n        => dacN(15),
         -- ADC[3:0] AXI Stream Interface
         m0_axis_aresetn => rfdcRstL,
         m0_axis_aclk    => rfdcClk,
         m00_axis_tdata  => rfdcAdc(0),
         m00_axis_tvalid => rfdcValid(0),
         m00_axis_tready => '1',
         m01_axis_tdata  => rfdcAdc(1),
         m01_axis_tvalid => rfdcValid(1),
         m01_axis_tready => '1',
         m02_axis_tdata  => rfdcAdc(2),
         m02_axis_tvalid => rfdcValid(2),
         m02_axis_tready => '1',
         m03_axis_tdata  => rfdcAdc(3),
         m03_axis_tvalid => rfdcValid(3),
         m03_axis_tready => '1',
         -- ADC[7:4] AXI Stream Interface
         m1_axis_aresetn => rfdcRstL,
         m1_axis_aclk    => rfdcClk,
         m10_axis_tdata  => rfdcAdc(4),
         m10_axis_tvalid => rfdcValid(4),
         m10_axis_tready => '1',
         m11_axis_tdata  => rfdcAdc(5),
         m11_axis_tvalid => rfdcValid(5),
         m11_axis_tready => '1',
         m12_axis_tdata  => rfdcAdc(6),
         m12_axis_tvalid => rfdcValid(6),
         m12_axis_tready => '1',
         m13_axis_tdata  => rfdcAdc(7),
         m13_axis_tvalid => rfdcValid(7),
         m13_axis_tready => '1',
         -- ADC[11:8] AXI Stream Interface
         m2_axis_aresetn => rfdcRstL,
         m2_axis_aclk    => rfdcClk,
         m20_axis_tdata  => rfdcAdc(8),
         m20_axis_tvalid => rfdcValid(8),
         m20_axis_tready => '1',
         m21_axis_tdata  => rfdcAdc(9),
         m21_axis_tvalid => rfdcValid(9),
         m21_axis_tready => '1',
         m22_axis_tdata  => rfdcAdc(10),
         m22_axis_tvalid => rfdcValid(10),
         m22_axis_tready => '1',
         m23_axis_tdata  => rfdcAdc(11),
         m23_axis_tvalid => rfdcValid(11),
         m23_axis_tready => '1',
         -- ADC[15:12] AXI Stream Interface
         m3_axis_aresetn => rfdcRstL,
         m3_axis_aclk    => rfdcClk,
         m30_axis_tdata  => rfdcAdc(12),
         m30_axis_tvalid => rfdcValid(12),
         m30_axis_tready => '1',
         m31_axis_tdata  => rfdcAdc(13),
         m31_axis_tvalid => rfdcValid(13),
         m31_axis_tready => '1',
         m32_axis_tdata  => rfdcAdc(14),
         m32_axis_tvalid => rfdcValid(14),
         m32_axis_tready => '1',
         m33_axis_tdata  => rfdcAdc(15),
         m33_axis_tvalid => rfdcValid(15),
         m33_axis_tready => '1',
         -- DAC[3:0] AXI Stream Interface
         s0_axis_aresetn => dspResetL,
         s0_axis_aclk    => dspClock,
         s00_axis_tdata  => rfdcDac(0),
         s00_axis_tvalid => '1',
         s00_axis_tready => open,
         s01_axis_tdata  => rfdcDac(1),
         s01_axis_tvalid => '1',
         s01_axis_tready => open,
         s02_axis_tdata  => rfdcDac(2),
         s02_axis_tvalid => '1',
         s02_axis_tready => open,
         s03_axis_tdata  => rfdcDac(3),
         s03_axis_tvalid => '1',
         s03_axis_tready => open,
         -- DAC[7:4] AXI Stream Interface
         s1_axis_aresetn => dspResetL,
         s1_axis_aclk    => dspClock,
         s10_axis_tdata  => rfdcDac(4),
         s10_axis_tvalid => '1',
         s10_axis_tready => open,
         s11_axis_tdata  => rfdcDac(5),
         s11_axis_tvalid => '1',
         s11_axis_tready => open,
         s12_axis_tdata  => rfdcDac(6),
         s12_axis_tvalid => '1',
         s12_axis_tready => open,
         s13_axis_tdata  => rfdcDac(7),
         s13_axis_tvalid => '1',
         s13_axis_tready => open,
         -- DAC[11:8] AXI Stream Interface
         s2_axis_aresetn => dspResetL,
         s2_axis_aclk    => dspClock,
         s20_axis_tdata  => rfdcDac(8),
         s20_axis_tvalid => '1',
         s20_axis_tready => open,
         s21_axis_tdata  => rfdcDac(9),
         s21_axis_tvalid => '1',
         s21_axis_tready => open,
         s22_axis_tdata  => rfdcDac(10),
         s22_axis_tvalid => '1',
         s22_axis_tready => open,
         s23_axis_tdata  => rfdcDac(11),
         s23_axis_tvalid => '1',
         s23_axis_tready => open,
         -- DAC[15:12] AXI Stream Interface
         s3_axis_aresetn => dspResetL,
         s3_axis_aclk    => dspClock,
         s30_axis_tdata  => rfdcDac(12),
         s30_axis_tvalid => '1',
         s30_axis_tready => open,
         s31_axis_tdata  => rfdcDac(13),
         s31_axis_tvalid => '1',
         s31_axis_tready => open,
         s32_axis_tdata  => rfdcDac(14),
         s32_axis_tvalid => '1',
         s32_axis_tready => open,
         s33_axis_tdata  => rfdcDac(15),
         s33_axis_tvalid => '1',
         s33_axis_tready => open);

   U_IBUFDS : IBUFDS
      port map(
         I  => plClkP,
         IB => plClkN,
         O  => refClk);

   U_Pll : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => true,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 2,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 2.0,      -- 500 MHz
         DIVCLK_DIVIDE_G   => 2,
         CLKFBOUT_MULT_G   => 5,        -- 1.25 GHz = 5 x 500 MHz /2
         CLKOUT0_DIVIDE_G  => 6,        -- 208.3 MHz = 1.25GHz/6
         CLKOUT1_DIVIDE_G  => 8)        -- 156.25 MHz = 1.25GHz/8
      port map(
         -- Clock Input
         clkIn     => refClk,
         rstIn     => axilRst,
         -- Clock Outputs
         clkOut(0) => rfdcClk,
         clkOut(1) => dspClock,
         -- Reset Outputs
         rstOut(0) => rfdcRst,
         rstOut(1) => dspReset);

   axilRstL  <= not(axilRst);
   rfdcRstL  <= not(rfdcRst);
   dspResetL <= not(dspReset);

   dspClk <= dspClock;
   dspRst <= dspReset;

   process(rfdcClk)
   begin
      -- Help with making timing
      if rising_edge(rfdcClk) then
         adc      <= rfdcAdc   after TPD_G;
         adcValid <= rfdcValid after TPD_G;
      end if;
   end process;

   process(dspClock)
   begin
      -- Help with making timing
      if rising_edge(dspClock) then
         rfdcDac <= dspDac after TPD_G;
      end if;
   end process;

   U_Gearbox : entity axi_soc_ultra_plus_core.Ssr12ToSsr16Gearbox
      generic map (
         TPD_G    => TPD_G,
         NUM_CH_G => 16)
      port map (
         -- Slave Interface
         wrClk  => rfdcClk,
         wrData => adc,
         -- Master Interface
         rdClk  => dspClock,
         rdRst  => dspReset,
         rdData => dspAdc);

end mapping;
