ARG BUILDER_IMAGE=index.docker.io/library/ubuntu@sha256:82becede498899ec668628e7cb0ad87b6e1c371cb8a1e597d83a47fac21d6af3
ARG RUNTIME_IMAGE=gcr.io/distroless/base@sha256:97f9cbf81590c7dd878d7e10c20116fa7488c2fb91b3c839df1ebdcb61ab13ca


FROM $BUILDER_IMAGE AS builder

	ARG VERSION=2.28.1
	ARG SHA256=91dd91e13f30fe520e01175ca1027dd09a458d4421a584ba557ba88b38803f27

	RUN set -ex && \
		apt update && \
		apt install -y curl gzip

	RUN set -ex && \
		curl -SOL https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz && \
		echo "${SHA256} prometheus-${VERSION}.linux-amd64.tar.gz" | sha256sum -c && \
		tar xvzf prometheus-${VERSION}.linux-amd64.tar.gz --strip-components=1 && \
		mv ./prometheus /usr/local/bin/prometheus

	RUN mkdir /data


FROM $RUNTIME_IMAGE

	COPY --from=builder --chown=nonroot:nonroot /data 		      /data
	COPY --from=builder --chown=nonroot:nonroot /usr/local/bin/prometheus /usr/local/bin/prometheus
	USER nonroot:nonroot

	ENTRYPOINT [ "prometheus" ]
