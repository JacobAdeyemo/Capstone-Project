build_dir=_build
nrfutil settings generate --family NRF52840 --application $build_dir/nrf52840_xxaa.hex --application-version 3 --bootloader-version 2 --bl-settings-version 1 $build_dir/bootloader.hex
mergehex -m $build_dir/bootloader.hex $build_dir/s140_nrf52_7.2.0_softdevice.hex $build_dir/nrf52840_xxaa.hex -o $build_dir/jhacee_prodboard_nrf52840_s140.hex
nrfjprog --family nrf52 -e
nrfjprog --family nrf52 --program $build_dir/jhacee_prodboard_nrf52840_s140.hex --verify
nrfjprog --family nrf52 -r
