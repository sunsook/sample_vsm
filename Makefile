# 차속 감시(VSM) 예제 - 1일차 오후 STATIC SE 실습용 배포 소스
#
# CC 는 STATIC SE 의 gcc 래퍼로 고정돼 있다 - 사전 준비 안내대로 Target IDE 래퍼 이름을 정확히 「GCC9.5」로
# 만들면 경로가 같아 Makefile 을 만지지 않고 그대로 빌드한다 (make clean 뒤 make).
# 래퍼 이름이 다르면 「gcc.exe 를 찾을 수 없다」로 빌드가 실패한다 - 사전 준비 안내 3장 · 문제 해결 참조.
# 원본 컴파일러(래퍼가 부르는 것)는 CT 가 설치한 gcc 9.5.0 (C:\Users\<계정>\CT\CodeScroll\Compiler\gcc\9.5.0\32bit\bin).
# make 는 CT 동봉 mingw32-make.exe - config.bat 로 PATH 를 잡고 make.cmd 로 부른다.
#
CC      = C:\Suresoft\STATIC-5\static-standalone\wrapper\GCC9.5\gcc.exe
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
	-cmd.exe /C del /Q $(subst /,\,$(OBJS)) $(TARGET)

# Git Bash 등 POSIX 셸용
clean-sh:
	-rm -f $(OBJS) $(TARGET)

.PHONY: all clean clean-sh
