apiVersion: v1
kind: Secret
metadata:
  name: ${CLUSTER_NAME}-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: ${CLUSTER_NAME}
  server: https://${SERVER_IP}:6443
  config: |
    {
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${CA_DATA}",
        "certData": "${CERT_DATA}",
        "keyData": "${KEY_DATA}"
      }
    }
