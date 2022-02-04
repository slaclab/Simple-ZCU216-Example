#-----------------------------------------------------------------------------
# This file is part of the 'SPACE SMURF RFSOC'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'SPACE SMURF RFSOC', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import time

import rogue
import rogue.interfaces.stream as stream
import rogue.utilities.fileio

import pyrogue as pr
import pyrogue.protocols
import pyrogue.utilities.fileio
import pyrogue.utilities.prbs

import simple_zcu216_example                 as rfsoc
import axi_soc_ultra_plus_core.rfsoc_utility as rfsoc_utility

rogue.Version.minVersion('5.10.0')

class Root(pr.Root):
    def __init__(self,
                 ip          = '10.0.0.200', # ETH Host Name (or IP address)
                 defaultFile = None,
                 **kwargs):

        # Pass custom value to parent via super function
        super().__init__(**kwargs)

        # Local Variables
        self.defaultFile = defaultFile

        # File writer
        self.dataWriter = pr.utilities.fileio.StreamWriter()
        self.add(self.dataWriter)

        ##################################################################################
        ##                              Register Access
        ##################################################################################

        # Start a TCP Bridge Client, Connect remote server at 'ethReg' ports 9000 & 9001.
        self.tcpReg = rogue.interfaces.memory.TcpClient(ip,9000)

        # Added the RFSoC HW device
        self.add(rfsoc.XilinxZcu216(
            memBase    = self.tcpReg,
            offset     = 0x04_0000_0000, # Full 40-bit address space
            expand     = True,
        ))

        ##################################################################################
        ##                              Data Path
        ##################################################################################

        # Create rogue stream arrays
        self.ringBufferAdc = [stream.TcpClient(ip,10000+2*(i+0))  for i in range(16)]
        self.ringBufferDac = [stream.TcpClient(ip,10000+2*(i+16)) for i in range(16)]
        self.adcRateDrop   = [stream.RateDrop(True,1.0) for i in range(16)]
        self.dacRateDrop   = [stream.RateDrop(True,1.0) for i in range(16)]
        self.adcProcessor  = [rfsoc_utility.RingBufferProcessor(name=f'AdcProcessor[{i}]',sampleRate=2.5E+9) for i in range(16)]
        self.dacProcessor  = [rfsoc_utility.RingBufferProcessor(name=f'DacProcessor[{i}]',sampleRate=2.5E+9) for i in range(16)]

        # Connect the rogue stream arrays
        for i in range(16):

            # ADC Ring Buffer Path
            self.ringBufferAdc[i] >> self.dataWriter.getChannel(i+0)
            self.ringBufferAdc[i] >> self.adcRateDrop[i] >> self.adcProcessor[i]
            self.add(self.adcProcessor[i])

            # DAC Ring Buffer Path
            self.ringBufferDac[i] >> self.dataWriter.getChannel(i+8)
            self.ringBufferDac[i] >> self.dacRateDrop[i] >> self.dacProcessor[i]
            self.add(self.dacProcessor[i])

    ##################################################################################

    def start(self,**kwargs):
        super(Root, self).start(**kwargs)

        # Useful pointers
        lmk      = self.XilinxZcu216.Hardware.Lmk
        i2cToSpi = self.XilinxZcu216.Hardware.I2cToSpi

        # Set the SPI clock rate
        i2cToSpi.SpiClockRate.setDisp('115kHz')

        # Configure the LMK for 4-wire SPI
        lmk.LmkReg_0x0000.set(value=0x10) # 4-wire SPI
        lmk.LmkReg_0x015F.set(value=0x3B) # STATUS_LD1 = SPI readback

        # Check for default file path
        if (self.defaultFile is not None) :

            # Load the Default YAML file
            print(f'Loading path={self.defaultFile} Default Configuration File...')
            self.LoadConfig(self.defaultFile)

            # Load the LMK configuration from the TICS Pro software HEX export
            for i in range(2): # Seems like 1st time after power up that need to load twice
                lmk.enable.set(True)
                lmk.PwrDwnLmkChip()
                lmk.PwrUpLmkChip()
                lmk.LoadCodeLoaderHexFile('config/lmk/HexRegisterValues.txt')
                lmk.Init()
                lmk.enable.set(False)

            # Reset the RF Data Converter
            self.XilinxZcu216.RfDataConverter.Reset.set(0x1)

            # Load the waveform data into DacSigGen
            self.XilinxZcu216.Application.DacSigGen.LoadCsvFile()

            # Update all SW remote registers
            self.ReadAll()

    ##################################################################################
