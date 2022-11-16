# Changelog

## 2022-11-16
- modified default links to point to lastest ORDS and APEX 22.2 and Tomcat 9.0.68
- add option to install a second pdb (xepdb2) export <br/>`USE_SECOND_PDB=true`
- add option `SECOND_POOL_NAME=build`<br/>to point to the second pdb incl. APEX instance for path access using <br/>
`.../ords/<option>/f?p=...`




## 2020-05-05

- Portainer removed
- dozzle included, but only local

## 2020-04-30

- Portainer included
- The Oracle client version is now variable
- JasperReportIntegration ist vorerst nicht mehr dabei
- Es wird nun geprüft, ob alle benötigten Dateien vorhanden sind
- APEX 20.1 is directly supported
- NodeProxy is updated
- SQLDeveloper Web could be used, when using ORDS 19.4
- Actual Version of required files are in place