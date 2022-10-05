package timestamp

import (
	"fmt"
	"os"
	"syscall"
	"time"

	"golang.org/x/sys/unix"
)

var (
	startTime time.Time
	lastTime  time.Time
	logPrefix = "## "
	indent    = 0
	enabled   = false
)

func statxTimestampToTime(sts unix.StatxTimestamp) time.Time {
	return time.Unix(sts.Sec, int64(sts.Nsec))
}

func init() {
	startTime = time.Now()
	lastTime = startTime

	for _, arg := range os.Args {
		if arg == "--timestamps" {
			enabled = true
		}
	}
}

func Print(str string) {
	if !enabled {
		return
	}
	now := time.Now()
	timestamp := now.Sub(startTime)
	if str[0] == '<' {
		indent -= 1
	}
	s := fmt.Sprintf("%s%5.1f %5.2f: %*s%s", logPrefix, timestamp.Seconds()*1000, now.Sub(lastTime).Seconds()*1000, indent*2, "", str)
	if str[0] == '>' {
		indent += 1
	}
	lastTime = now
	syscall.Access(s, 0)
	fmt.Println(s)
}
