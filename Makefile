# 차속 감시(VSM) 예제 - 일반 GCC 빌드
#
# 컴파일러는 setup.ps1 이 설치한 GCC(WinLibs 10.5.0 i686)를 쓴다 - 경로는 local.mk 에 기록된다.
# local.mk 가 없으면 PATH 의 gcc 를 쓴다.
# STATIC SE 래퍼로 빌드하려면 Makefile.static 을 쓴다 (mingw32-make -f Makefile.static).
#
CC      = gcc
-include local.mk

CFLAGS  = -std=c11 -Wall -Wextra -Iinclude

TARGET  = vsm_demo.exe
SRCS    = src/main.c src/speed_monitor.c src/sensor_filter.c src/diag_log.c
OBJS    = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Windows cmd / PowerShell 기준
clean:
	-cmd.exe /C del /Q $(subst /,\,$(OBJS)) $(TARGET) 2>nul

# Git Bash 등 POSIX 셸용
clean-sh:
	-rm -f $(OBJS) $(TARGET)

.PHONY: all clean clean-sh
