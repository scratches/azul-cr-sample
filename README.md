Demo project for Azul "cr" feature (faster cold start up using CRIU).

Prerequisite: `zulu-cr` as a tar ball (`zulu-*.tar.gz`). It bundles criu (and requires being run as root, or in `--privileged` mode with docker).

```
$ ./mvnw package
$ docker build -t demo .
$ docker run --name checkpoint --privileged demo
$ docker commit -c 'CMD ["sh", "-c", "exec java -cp app:app/lib/* com.example.ServerApplication"]' checkpoint demo-crac
$ docker run --privileged --rm demo-crac
```

Starts up about 30-40% faster.