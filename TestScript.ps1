$Body = @{
    operationType = "create"
    name = "Smith656"
    email = "xysdfs4df2@gmail.com"
    phone = "453256542645445"
    city = "NewYark2"
    country = "US2"
}
Invoke-RestMethod -Uri 'https://cloudquicklabs-func-app2.azurewebsites.net/api/demofunctionazure?code=g9cQzOX9CeSFx67akHwyYxmOTeHsJKbTKurqtK4xE5eOAzFubC5kMg==' -Body $Body