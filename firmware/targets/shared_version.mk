# Define Firmware Version: v1.9.0.0
export PRJ_VERSION = 0x01090000

# Include .XSA in image dir
export GEN_XSA_IMAGE = 1

# Define release
ifndef RELEASE
export RELEASE = all
endif
