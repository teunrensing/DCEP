PIO ?= pio
PORT ?=
ENV ?=
BAUD ?= 115200
BACKUP_DIR ?= backups

PIO_ENV :=
ifdef ENV
PIO_ENV := -e $(ENV)
endif

PIO_PORT :=
ifdef PORT
PIO_PORT := --upload-port $(PORT)
endif

.PHONY: help build upload monitor monitor-log test test-native coverage check tidy tidy-fix docs docs-serve docs-lint compiledb clean hooks ports size doctor release outdated deps-snapshot cache-stats cache-clear backup udev-rules all

help:
	@printf '%s\n' \
	  'PlatformIO commands:' \
	  '  make build           Build firmware' \
	  '  make upload          Upload firmware, optionally PORT=/dev/ttyUSB0' \
	  '  make monitor         Open serial monitor' \
	  '  make monitor-log     Open serial monitor and save logs/serial-*.log' \
	  '  make test            Run PlatformIO tests' \
	  '  make test-native     Run native Google Test tests' \
	  '  make coverage        Run native Google Test with gcovr coverage' \
	  '  make check           Run PlatformIO static analysis' \
	  '  make size            Show firmware memory usage' \
	  '  make ports           List connected serial devices' \
	  '  make doctor          Print local tool, device, and project status' \
	  '  make release         Build and collect local firmware artifacts' \
	  '  make outdated        Show outdated PlatformIO packages' \
	  '  make deps-snapshot   Save PlatformIO package list/outdated report' \
	  '  make cache-stats     Show ccache statistics' \
	  '  make cache-clear     Clear ccache' \
	  '  make backup          Create a local backup bundle/archive' \
	  '  make udev-rules      Install Linux debug probe udev rules' \
	  '  make tidy            Run clang-tidy over the project' \
	  '  make tidy-fix        Run clang-tidy and apply fixes' \
	  '  make docs            Generate Doxygen HTML docs' \
	  '  make docs-lint       Run docs/comment spell and Markdown checks' \
	  '  make docs-serve      Serve docs at http://localhost:8090' \
	  '  make compiledb       Generate compile_commands.json for clangd' \
	  '  make hooks           Install optional Git hooks' \
	  '  make clean           Clean PlatformIO build output' \
	  '' \
	  'Use ENV=name to select a PlatformIO env: make build ENV=debug'

build:
	$(PIO) run $(PIO_ENV)

upload:
	$(PIO) run $(PIO_ENV) -t upload $(PIO_PORT)

monitor:
	$(PIO) device monitor

monitor-log:
	PORT="$(PORT)" BAUD="$(BAUD)" .devenvironment/monitor-log.sh

test:
	$(PIO) test $(PIO_ENV)

test-native:
	$(PIO) test -e native

coverage:
	.devenvironment/coverage.sh

check:
	$(PIO) check $(PIO_ENV) --fail-on-defect medium

size:
	$(PIO) run $(PIO_ENV) -t size

ports:
	$(PIO) device list

doctor:
	.devenvironment/doctor.sh

release:
	ENV="$(ENV)" .devenvironment/release-build.sh

outdated:
	$(PIO) pkg outdated

deps-snapshot:
	.devenvironment/dependency-snapshot.sh

cache-stats:
	ccache --show-stats

cache-clear:
	ccache --clear

backup:
	BACKUP_DIR="$(BACKUP_DIR)" .devenvironment/backup.sh

udev-rules:
	.devenvironment/install-udev-rules.sh

tidy:
	ENV="$(ENV)" .devenvironment/run-clang-tidy.sh

tidy-fix:
	ENV="$(ENV)" FIX=1 .devenvironment/run-clang-tidy.sh

docs:
	.devenvironment/generate-docs.sh

docs-serve: docs
	python3 -m http.server 8090 --directory docs/doxygen/html

compiledb:
	.devenvironment/generate-compile-db.sh $(PIO_ENV)

clean:
	$(PIO) run $(PIO_ENV) -t clean

hooks:
	.devenvironment/install-git-hooks.sh

all: compiledb build check tidy docs
