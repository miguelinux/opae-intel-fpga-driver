KERNELDIR ?=  /lib/modules/$(shell uname -r)/build
PWD ?= $(pwd)

cflags-y +=  -Wno-unused-value -Wno-unused-label -I $(PWD)/include -I $(PWD)/include/uapi -I $(PWD)/include/intel
cflags-y +=	-I $(DESTDIR)/usr/src/intel-fpga-0.13.0/include -I $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/uapi -I $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/intel
cflags-y += -I $(PWD)/build/include -I $(PWD)/build/include/uapi -I $(PWD)/build/include/intel

ccflags-y +=  -Wno-unused-value -Wno-unused-label -I $(PWD)/include -I $(PWD)/include/uapi -I $(PWD)/include/intel
ccflags-y +=	-I $(DESTDIR)/usr/src/intel-fpga-0.13.0/include -I $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/uapi -I $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/intel
ccflags-y += -I $(PWD)/build/include -I $(PWD)/build/include/uapi -I $(PWD)/build/include/intel
ccflags-y += -DCONFIG_AS_AVX512

obj-m := spi-nor-mod.o
obj-m += altera-asmip2.o
obj-m += fpga-mgr-mod.o
obj-m += intel-fpga-pci.o
obj-m += intel-fpga-fme.o
obj-m += intel-fpga-afu.o

spi-nor-mod-y := drivers/mtd/spi-nor/spi-nor.o

altera-asmip2-y := drivers/mtd/spi-nor/altera-asmip2.o

fpga-mgr-mod-y := drivers/fpga/fpga-mgr.o

intel-fpga-pci-y := drivers/fpga/intel/uuid_mod.o
intel-fpga-pci-y += drivers/fpga/intel/pcie.o
intel-fpga-pci-y += drivers/fpga/intel/pcie_check.o
intel-fpga-pci-y += drivers/fpga/intel/feature-dev.o

intel-fpga-fme-y := drivers/fpga/intel/fme-pr.o
intel-fpga-fme-y += drivers/fpga/intel/fme-iperf.o
intel-fpga-fme-y += drivers/fpga/intel/fme-dperf.o
intel-fpga-fme-y += drivers/fpga/intel/fme-error.o
intel-fpga-fme-y += drivers/fpga/intel/fme-main.o
intel-fpga-fme-y += drivers/fpga/intel/backport.o

intel-fpga-afu-y := drivers/fpga/intel/afu.o
intel-fpga-afu-y += drivers/fpga/intel/region.o
intel-fpga-afu-y += drivers/fpga/intel/dma-region.o
intel-fpga-afu-y += drivers/fpga/intel/afu-error.o
intel-fpga-afu-y += drivers/fpga/intel/afu-check.o

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

install-drv:
	cp 40-intel-fpga.rules /etc/udev/rules.d
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules_install
	depmod
	modprobe spi-nor-mod
	modprobe altera-asmip2
	modprobe fpga-mgr-mod
	modprobe intel-fpga-pci
	modprobe intel-fpga-afu
	modprobe intel-fpga-fme

install-src:
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/intel
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/linux/fpga
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/linux/mtd
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/uapi/linux
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/drivers/fpga/intel
	mkdir -p $(DESTDIR)/usr/src/intel-fpga-0.13.0/drivers/mtd/spi-nor

	cp -f include/*.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/
	cp -f include/intel/*.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/intel/
	cp -f include/linux/fpga/*.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/linux/fpga/
	cp -f include/linux/mtd/spi-nor-mod.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/linux/mtd/
	cp -f include/linux/iopoll-mod.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/linux
	cp -f include/linux/mtd/altera-asmip2.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/linux/mtd/
	cp -f include/uapi/linux/*.h $(DESTDIR)/usr/src/intel-fpga-0.13.0/include/uapi/linux/

	cp -f drivers/mtd/spi-nor/spi-nor.c $(DESTDIR)/usr/src/intel-fpga-0.13.0/drivers/mtd/spi-nor
	cp -f drivers/mtd/spi-nor/altera-asmip2.c $(DESTDIR)/usr/src/intel-fpga-0.13.0/drivers/mtd/spi-nor
	cp -f drivers/fpga/*.c $(DESTDIR)/usr/src/intel-fpga-0.13.0/drivers/fpga/
	cp -f drivers/fpga/intel/*.c $(DESTDIR)/usr/src/intel-fpga-0.13.0/drivers/fpga/intel/

	cp -f Makefile $(DESTDIR)/usr/src/intel-fpga-0.13.0/

	cp -f *.sh $(DESTDIR)/usr/src/intel-fpga-0.13.0/
	cp -f dkms.conf $(DESTDIR)/usr/src/intel-fpga-0.13.0/

	cp -f *.rules $(DESTDIR)/usr/src/intel-fpga-0.13.0/

install : install-src
	dkms add -m intel-fpga -v 0.13.0
	dkms build -m intel-fpga -v 0.13.0
	dkms install -m intel-fpga -v 0.13.0

clean:
	INTEL_FPGA_DIR=$(PWD) $(MAKE) -C $(KERNELDIR) M=$(PWD) clean
