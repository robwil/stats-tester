package main

import (
    "github.com/DataDog/datadog-go/statsd"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"
)

const N = 100

func main() {
    c, err := statsd.New("127.0.0.1:8125")
    if err != nil {
        log.Fatal(err)
    }
    // prefix every metric with the app name
    c.Namespace = "test."


    for i := 0; i < N; i++ {
        ticker := time.NewTicker(time.Millisecond * 5)
        go func() {
            for range ticker.C {
                if err := c.Incr("counter", nil, 1); err != nil {
                    log.Println("WARN: failed to send metric")
                }
            }
        }()
    }

    osSignals := make(chan os.Signal)
    signal.Notify(osSignals, syscall.SIGINT, syscall.SIGTERM)

    for {
        select {
        case <-osSignals:
            log.Println("shutdown signal received, beginning shutdown...")
            return
        }
    }
}
