# cosigntest
Dummy repo to test signing container images using sigstore


cosign verify \
    --certificate-github-workflow-repository nubificus/cosigntest \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    --certificate-identity "https://github.com/nubificus/cosigntest/.github/workflows/oci.yml@refs/tags/v0.1.0" \
    "harbor.nbfc.io/nbfc/cosigntest:main"