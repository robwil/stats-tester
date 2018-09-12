# stats-tester

This simple Go app is meant to test the pushing of StatsD metrics via a Datadog agent
running as a Kubernetes service. It was created to help debug an issue within GKE where
it appears that services do not evenly distribute traffic.