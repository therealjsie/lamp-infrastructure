# Based on: https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/getting-started/usage/
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-secrets-csi-provider
  namespace: {{ .Values.appName }}
spec:
  provider: azure
  secretObjects:
  - secretName: database-config
    type: Opaque
    data: 
    - objectName: "database-password"
      key: database-password
    - objectName: "database-connection-string"
      key: database-connection-string
  parameters:
    keyvaultName: {{ .Values.keyVaultName }} 
    tenantId: {{ .Values.tenantId }} 
    userAssignedIdentityID: {{ .Values.secretProviderIdentityId }}
    useVMManagedIdentity: "true"
    objects:  |
      array:
        - |
          objectName: database-password
          objectType: secret
        - |
          objectName: database-connection-string
          objectType: secret