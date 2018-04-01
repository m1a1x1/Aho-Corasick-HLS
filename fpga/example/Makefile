PROJECT=test
QSYS_NAME=soc_system
OUTPUT_DIR=output_files
QSYS_DIR=soc_files

defaut:
	quartus_map $(PROJECT)
	quartus_fit $(PROJECT)
	quartus_asm $(PROJECT)
	quartus_cpf -c $(OUTPUT_DIR)/$(PROJECT).sof $(OUTPUT_DIR)/$(PROJECT).rbf
	cat $(OUTPUT_DIR)/$(PROJECT).fit.summary
clean:
	rm -r *db $(PROJECT).qws *.qdf *.json *.txt *.csv simulation

qsys_gen:
	qsys-generate $(QSYS_DIR)/$(QSYS_NAME).qsys -syn

qsys-clean:
	rm -r $(QSYS_DIR)/$(QSYS_NAME) $(QSYS_DIR)/*.sopcinfo

gen_preloader_uboot:
	bsp-create-settings --type spl --bsp-dir build --preloader-settings-dir $(QSYS_NAME)_hps_0 --settings build/settings.bsp --set spl.boot.WATCHDOG_ENABLE false
	make -C build 
	make -C build uboot
