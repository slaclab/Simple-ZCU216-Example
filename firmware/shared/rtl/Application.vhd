-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Application Module
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

entity Application is
   generic (
      TPD_G            : time := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- DMA Interface (dmaClk domain)
      dmaClk          : in  sl;
      dmaRst          : in  sl;
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      -- ADC/DAC Interface (dspClk domain)
      dspClk          : in  sl;
      dspRst          : in  sl;
      dspAdc          : in  Slv256Array(15 downto 0);
      dspDac          : out Slv256Array(15 downto 0);
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType);
end Application;

architecture mapping of Application is

   constant NUM_ADC_CH_C     : positive := 16;
   constant NUM_DAC_CH_C     : positive := 16;
   constant RAM_ADDR_WIDTH_C : positive := 10;

   constant RING_INDEX_C       : natural := 0;
   constant DAC_SIG_INDEX_C    : natural := 1;
   constant NUM_AXIL_MASTERS_C : natural := 2;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 28, 24);

   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal adc      : Slv256Array(15 downto 0) := (others => (others => '0'));
   signal dac      : Slv256Array(15 downto 0) := (others => (others => '0'));
   signal loopback : Slv256Array(15 downto 0) := (others => (others => '0'));

begin

   process(dspClk)
   begin
      -- Help with making timing
      if rising_edge(dspClk) then
         adc    <= dspAdc after TPD_G;
         dspDac <= dac    after TPD_G;
      end if;
   end process;

   -- Loopback
   loopback <= adc;

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   U_AppRingBuffer : entity axi_soc_ultra_plus_core.AppRingBuffer
      generic map (
         TPD_G                  => TPD_G,
         EN_ADC_BUFF_G          => true,
         EN_DAC_BUFF_G          => true,
         NUM_ADC_CH_G           => NUM_ADC_CH_C,
         NUM_DAC_CH_G           => NUM_DAC_CH_C,
         ADC_SAMPLE_PER_CYCLE_G => SAMPLE_PER_CYCLE_C,
         DAC_SAMPLE_PER_CYCLE_G => SAMPLE_PER_CYCLE_C,
         RAM_ADDR_WIDTH_G       => RAM_ADDR_WIDTH_C,
         AXIL_BASE_ADDR_G       => AXIL_CONFIG_C(RING_INDEX_C).baseAddr)
      port map (
         -- DMA Interface (dmaClk domain)
         dmaClk          => dmaClk,
         dmaRst          => dmaRst,
         dmaIbMaster     => dmaIbMaster,
         dmaIbSlave      => dmaIbSlave,
         -- ADC/DAC Interface (dspClk domain)
         dspClk          => dspClk,
         dspRst          => dspRst,
         dspAdc0         => adc(0),
         dspAdc1         => adc(1),
         dspAdc2         => adc(2),
         dspAdc3         => adc(3),
         dspAdc4         => adc(4),
         dspAdc5         => adc(5),
         dspAdc6         => adc(6),
         dspAdc7         => adc(7),
         dspAdc8         => adc(8),
         dspAdc9         => adc(9),
         dspAdc10        => adc(10),
         dspAdc11        => adc(11),
         dspAdc12        => adc(12),
         dspAdc13        => adc(13),
         dspAdc14        => adc(14),
         dspAdc15        => adc(15),
         dspDac0         => dac(0),
         dspDac1         => dac(1),
         dspDac2         => dac(2),
         dspDac3         => dac(3),
         dspDac4         => dac(4),
         dspDac5         => dac(5),
         dspDac6         => dac(6),
         dspDac7         => dac(7),
         dspDac8         => dac(8),
         dspDac9         => dac(9),
         dspDac10        => dac(10),
         dspDac11        => dac(11),
         dspDac12        => dac(12),
         dspDac13        => dac(13),
         dspDac14        => dac(14),
         dspDac15        => dac(15),
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(RING_INDEX_C),
         axilReadSlave   => axilReadSlaves(RING_INDEX_C),
         axilWriteMaster => axilWriteMasters(RING_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(RING_INDEX_C));

   U_DacSigGen : entity axi_soc_ultra_plus_core.SigGen
      generic map (
         TPD_G              => TPD_G,
         NUM_CH_G           => 16,
         RAM_ADDR_WIDTH_G   => RAM_ADDR_WIDTH_C,
         SAMPLE_PER_CYCLE_G => SAMPLE_PER_CYCLE_C,
         AXIL_BASE_ADDR_G   => AXIL_CONFIG_C(DAC_SIG_INDEX_C).baseAddr)
      port map (
         -- DAC Interface (dspClk domain)
         dspClk          => dspClk,
         dspRst          => dspRst,
         dspDacIn0       => loopback(0),
         dspDacIn1       => loopback(1),
         dspDacIn2       => loopback(2),
         dspDacIn3       => loopback(3),
         dspDacIn4       => loopback(4),
         dspDacIn5       => loopback(5),
         dspDacIn6       => loopback(6),
         dspDacIn7       => loopback(7),
         dspDacIn8       => loopback(8),
         dspDacIn9       => loopback(9),
         dspDacIn10      => loopback(10),
         dspDacIn11      => loopback(11),
         dspDacIn12      => loopback(12),
         dspDacIn13      => loopback(13),
         dspDacIn14      => loopback(14),
         dspDacIn15      => loopback(15),
         dspDacOut0      => dac(0),
         dspDacOut1      => dac(1),
         dspDacOut2      => dac(2),
         dspDacOut3      => dac(3),
         dspDacOut4      => dac(4),
         dspDacOut5      => dac(5),
         dspDacOut6      => dac(6),
         dspDacOut7      => dac(7),
         dspDacOut8      => dac(8),
         dspDacOut9      => dac(9),
         dspDacOut10     => dac(10),
         dspDacOut11     => dac(11),
         dspDacOut12     => dac(12),
         dspDacOut13     => dac(13),
         dspDacOut14     => dac(14),
         dspDacOut15     => dac(15),
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(DAC_SIG_INDEX_C),
         axilReadSlave   => axilReadSlaves(DAC_SIG_INDEX_C),
         axilWriteMaster => axilWriteMasters(DAC_SIG_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(DAC_SIG_INDEX_C));

end mapping;
