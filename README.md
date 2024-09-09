# cosigntest

Dummy repo to test signing container images using `sigstore`.

## Build the image

The Github action defined in [oci.yml](.github/workflows/oci.yml) builds a container image with the dummy Go application, pushes it to [harbor.nbfc.io](https://harbor.nbfc.io/harbor/projects/2/repositories/cosigntest) and signs it using `cosign`. The signing process is performed in keyless mode utilizing the OIDC token provided by the Github workflow run. Some optional annotations are passed to provide supplementary details for the container image.

## Verify the image 

For basic verification:

```bash
cosign verify harbor.nbfc.io/nubificus/cosigntest:nbfc-0966adc \
  --certificate-github-workflow-repository nubificus/cosigntest \
  --certificate-identity "https://github.com/nubificus/cosigntest/.github/workflows/oci.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" 
```

For verification with additional details provided by GitHub:

```bash
cosign verify harbor.nbfc.io/nubificus/cosigntest:nbfc-0966adc \
  --certificate-github-workflow-repository nubificus/cosigntest \
  --certificate-identity "https://github.com/nubificus/cosigntest/.github/workflows/oci.yml@refs/heads/main" \
  --certificate-github-workflow-name "OCI image push" \
  --certificate-github-workflow-ref refs/heads/main \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

For verification with our custom annotations:

```bash
cosign verify harbor.nbfc.io/nubificus/cosigntest:nbfc-0966adc \
  --certificate-github-workflow-repository nubificus/cosigntest \
  --certificate-identity "https://github.com/nubificus/cosigntest/.github/workflows/oci.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" /
  -a 'author=Nubificus LTD'
```

For verification using wildcards:

```bash
cosign verify harbor.nbfc.io/nubificus/cosigntest:nbfc-0966adc \
  --certificate-identity-regexp="^https:\/\/github\.com\/nubificus\/" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  -a 'author=Nubificus LTD'
```

For verification in Kubernetes clusters we could use a [policy controller](https://github.com/sigstore/helm-charts/tree/main/charts/policy-controller#deploy-policy-controller-helm-chart).

Then we can create a new policy:

```yaml
apiVersion: v1                                                                                                                                                                                             
kind: Namespace                                                                                                                                                                             
metadata:                                                                                                                                               
  labels:                                                                                                                                                                                            
    policy.sigstore.dev/include: "true"                                                                                                                                                                      
    kubernetes.io/metadata.name: test-policy                                                                                                                                                       
  name: test-policy                                                                                                                                                                                          
spec:                                                                                                                                                                                                       
  finalizers:                                                                                                                                                                                               
  - kubernetes
```

And add your cluster image policy:

```yaml
apiVersion: policy.sigstore.dev/v1beta1                                                                                                                                                                    
kind: ClusterImagePolicy                                                                                                                                                                                    
metadata:                                                                                                                                                                                                  
  name: nbfc-policy                                                                                                                                                                                        
spec:                                                                                                                                                                                                      
  authorities:                                                                                                                                                                                             
  - keyless:                                                                                                                                                                                              
      identities:                                                                                                                                                                                          
      - issuer: https://token.actions.githubusercontent.com                                                                                                                                            
        subjectRegExp: https://github.com/nubificus/.*/.github/workflows/*@*                                                                                                                              
      url: https://fulcio.sigstore.dev                                                                                                                                                                     
    name: authority-0                                                                                                                                                                                   
  images:                                                                                                                                                                                              
  - glob: '**'
  mode: enforce
```
```
{"apiVersion":"policy.sigstore.dev/v1beta1","kind":"ClusterImagePolicy","metadata":{"annotations":{},"name":"nbfc-policy"},"spec":{"authorities":[{"keyless":{"identities":[{"issuer":"https://token.│·····
actions.githubusercontent.com","subjectRegExp":"https://github.com/nubificus/.*/.github/workflows/*@*"}]}}],"images":[{"glob":"**"}]}}
```
