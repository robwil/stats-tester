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
    c, err := statsd.New("datadog-service2:8125")
    if err != nil {
        log.Fatal(err)
    }
    podName := os.Getenv("POD_NAME")
    if podName == "" {
        log.Fatal("expected POD_NAME envvar")
    }
    // prefix every metric with the app name
    c.Namespace = "test."
    c.Tags = []string{"pod:" + podName}

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
