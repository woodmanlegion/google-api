.PHONY: install-termux install-debian install-windows

install-termux:
	bash install/termux.sh

install-debian:
	bash install/debian.sh

install-windows:
	powershell -ExecutionPolicy Bypass -File install/windows.ps1
