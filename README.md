[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjosh-robinson-swx%2FBicep-Testing%2Fmain%2FDiag-Settings-Template.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjosh-robinson-swx%2FBicep-Testing%2Fmain%2FcreateUiDefinition.json)




a Quick deployment of Azure policies to stream diagnostic settings to a log analytics workspace for various Azure resources already existing and future created resources too.

An exclusion box for each resource is present during deployment for any resources which do not need diagnostic settings streamed.

A textbox is also present during deployment, please input the name of the log analytics workspace you want the diagnostic settings streamed to in this.
