# file: Makfile
#
# Makefile for building the flash boot copiers
# dvb 2004
#
# Cleaned up, added pattern rules, jrk, 2009
#
# ex:set noexpandtab:

.NOTPARALLEL:
SHELL := /bin/bash

S = @
E = @echo

# EPCS & CFI intermediate object files are separated,
# because common code (in boot_loader.S) is pre-processed
# differently for CFI & EPCS flash. This enables the clean
# use of pattern rules to build the intermediates.
#
# The executables are all uniquely named, though, so these
# can all reside in the traditional $(OBJ)
OBJ = ./obj
OBJ_EPCS = ./obj_epcs

ifeq ("$(S)","@")
 DASH_S = -s
endif


# |
# | The code is fully relocatable. However! You may
# | wish to compile an elf for faux-debugging that
# | claims to be at a particular location (like where
# | your flash or epcs device is). To do this,
# | type "make CODE_BASE=0x<epcs_base>". The assignment
# | here uses it appropriately. dvb2004
# |

ifneq ("$(CODE_BASE)","")
 CODE_BASE_OPT = -Ttext=$(CODE_BASE)
else
# | default CODE_BASE to 0x0
 CODE_BASE_OPT = -Ttext=0x0
endif

ifneq ("$(EPCS_REGS_BASE)","")
 EPCS_REGS_BASE_OPT = -DEPCS_REGS_BASE=$(EPCS_REGS_BASE)
endif

ifneq ("$(EPCS_SIMULATION_TEST)","")
 EPCS_SIMULATION_TEST_OPT = -DEPCS_SIMULATION_TEST
endif

ifneq ("$(EPCS_SIMULATION_TEST_FLASH_BASE)","")
 EPCS_SIMULATION_TEST_FLASH_BASE_OPT = -DEPCS_SIMULATION_TEST_FLASH_BASE=$(EPCS_SIMULATION_TEST_FLASH_BASE)
 CODE_BASE_OPT += -Tdata=$(EPCS_SIMULATION_TEST_FLASH_BASE)
endif

EPCS_OPTS = -DEPCS \
            $(EPCS_REGS_BASE_OPT) \
            $(EPCS_SIMULATION_TEST_OPT) \
            $(EPCS_SIMULATION_TEST_FLASH_BASE_OPT)
SRECS = \
	boot_loader_cfi.srec \
	boot_loader_epcs.srec \
	boot_loader_epcs_sii_siii_ciii.srec \
	boot_loader_cfi_be.srec \
	boot_loader_epcs_be.srec \
	boot_loader_epcs_sii_siii_ciii_be.srec \
	boot_loader_epcq256_cv.srec \
	boot_loader_epcs_cv.srec \
	boot_loader_universal.srec

ALL_TARGS = \
	$(SRECS) \
	$(OBJ)/boot_loader_cfi.elf \
	$(OBJ)/boot_loader_cfi.objdump \
	$(OBJ)/boot_loader_cfi.nm \
	$(OBJ)/boot_loader_epcs.elf \
	$(OBJ)/boot_loader_epcs.objdump \
	$(OBJ)/boot_loader_epcs.nm \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii.elf \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii.objdump \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii.nm \
	$(OBJ)/boot_loader_cfi_be.elf \
	$(OBJ)/boot_loader_cfi_be.objdump \
	$(OBJ)/boot_loader_cfi_be.nm \
	$(OBJ)/boot_loader_epcs_be.elf \
	$(OBJ)/boot_loader_epcs_be.objdump \
	$(OBJ)/boot_loader_epcs_be.nm \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.elf \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.objdump \
	$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.nm \
	$(OBJ)/boot_loader_epcq256_cv.elf \
	$(OBJ)/boot_loader_epcq256_cv.objdump \
	$(OBJ)/boot_loader_epcq256_cv.nm \
	$(OBJ)/boot_loader_epcs_cv.elf \
	$(OBJ)/boot_loader_epcs_cv.objdump \
	$(OBJ)/boot_loader_epcs_cv.nm \
	$(OBJ)/boot_loader_universal.elf \
	$(OBJ)/boot_loader_universal.objdump \
	$(OBJ)/boot_loader_universal.nm
.PHONY: all
all : $(OBJ)
	$(S)$(MAKE) $(DASH_S) S=$(S) xall

.PHONY: xall
xall : $(ALL_TARGS)
	$(E) "Try \"make clean all S=\" to see more detailed spew."
	$(E) Done

.PHONY: clean
clean :
	$(E) Cleaning up
	$(S)rm -vf $(ALL_TARGS)
	$(S)rm -vf $(OBJ)/*.s
	$(S)rm -vf $(OBJ_EPCS)/*.s

.PHONY: install
install : $(SRECS)
ifneq ("$(DEST_PATH)","")
	$(E) Copying $(SRECS)
	$(E) To $(DEST_PATH)
	$(S)cp -f $(SRECS) $(DEST_PATH)
endif

$(OBJ) :
	$(E) Creating $@
	$(S)mkdir -p $@

$(OBJ_EPCS) :
	$(E) Creating $@
	$(S)mkdir -p $@

########################
# CFI Flash boot loader
#######################
BOOT_LOADER_CFI_OBJS = \
	$(OBJ)/boot_loader.s \
	$(OBJ)/boot_loader_cfi_bits.s

$(OBJ)/%.s : %.S $(OBJ)
	$(E) Pre-processing $<
	$(S)nios2-elf-cpp $< -o $@ $(CODE_BASE_OPT)

$(OBJ)/boot_loader_cfi.elf : \
	$(BOOT_LOADER_CFI_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_CFI_OBJS) \
		$(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

$(OBJ)/boot_loader_cfi_be.elf : \
	$(BOOT_LOADER_CFI_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -meb -nostdlib \
		$(BOOT_LOADER_CFI_OBJS) \
		$(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# EPCS Flash boot loader: Cyclone I & Cyclone II
###################################################
$(OBJ_EPCS)/%.s : %.S $(OBJ_EPCS)
	$(E) Pre-processing $<
	$(S)nios2-elf-cpp $< -o $@ $(CODE_BASE_OPT) $(EPCS_OPTS)

BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits_cyclone.s

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_epcs.elf : \
	$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

$(OBJ)/boot_loader_epcs_be.elf : \
	$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -meb -nostdlib \
		$(BOOT_LOADER_EPCS_CYCLONEI_CYCLONEII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# EPCS for Cyclone III, Sratix II-IV, Arria I-II
###################################################

# Note: pattern rule for EPCS objects was created above
BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits_sii_siii_ciii.s

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_epcs_sii_siii_ciii.elf : \
	$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

$(OBJ)/boot_loader_epcs_sii_siii_ciii_be.elf : \
	$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -meb -nostdlib \
		$(BOOT_LOADER_EPCS_SII_SIII_CIII_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# Boot copier for Family V EPCQ 256
###################################################

# Note: pattern rule for EPCS objects was created above
BOOT_LOADER_EPCQ256_CV_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_epcq256_bits_cv.s

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_EPCQ256_CV_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_epcq256_cv.elf : \
	$(BOOT_LOADER_EPCQ256_CV_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_EPCQ256_CV_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# Boot copier for Family V EPCS
###################################################

# Note: pattern rule for EPCS objects was created above
BOOT_LOADER_EPCS_CV_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits_cv.s

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_EPCS_CV_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_epcs_cv.elf : \
	$(BOOT_LOADER_EPCS_CV_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_EPCS_CV_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# Universal Boot copier for Family V and later
# It won't care whether EPCS/EPCQ, compressed or uncompressed
###################################################

# Note: pattern rule for EPCS objects was created above
BOOT_LOADER_UNIVERSAL_OBJS = \
	$(OBJ_EPCS)/boot_loader.s \
	$(OBJ_EPCS)/boot_loader_epcs_bits.s \
	$(OBJ_EPCS)/boot_loader_universal_bits.s

# EPCS testing may provide an additional source file for a flash image
ifneq ("$(EPCS_SIMULATION_TEST_FLASH_IMAGE)","")
BOOT_LOADER_UNIVERSAL_OBJS += $(OBJ_EPCS)/$(EPCS_SIMULATION_TEST_FLASH_IMAGE)
endif

$(OBJ)/boot_loader_universal.elf : \
	$(BOOT_LOADER_UNIVERSAL_OBJS)
	$(E) Compiling to $@
	$(S)nios2-elf-gcc -nostdlib \
		$(BOOT_LOADER_UNIVERSAL_OBJS) \
		$(EPCS_OPTS) $(CODE_BASE_OPT) \
		-gdwarf2 -Wa,-gdwarf2 \
		-o $@

###################################################
# Utility & executable file pattern rules
###################################################
$(OBJ)/%.objdump : $(OBJ)/%.elf $(OBJ)
	$(E) Objdumping $<
	$(S)nios2-elf-objdump -D --source $< > $@

$(OBJ)/%.nm : $(OBJ)/%.elf $(OBJ)
	$(E) Nm-ing $<
	$(S)nios2-elf-nm $< | sort > $@

%.srec : $(OBJ)/%.elf $(OBJ)
	$(E) Creating SREC file $@
	$(S)nios2-elf-objcopy --output-target=srec $< $@

.PHONY: help
help :
	@echo .
	@echo . Here is a typical run-from-RAM command
	@echo . make CODE_BASE=0x1000000 EPCS_REGS_BASE=0x900400 clean all
	@echo .

# end of file
