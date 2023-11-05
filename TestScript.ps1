$Body = @{
    operationType = "create"
    name = "Smith"
    email = "xysdfsdf@gmail.com"
    phone = "45325654645"
    city = "NewYark"
    country = "US"
}
Invoke-RestMethod -Uri 'https://cloudquicklabs-func-app2.azurewebsites.net/api/demofunctionazure?code=g9cQzOX9CeSFx67akHwyYxmOTeHsJKbTKurqtK4xE5eOAzFubC5kMg==' -Body $Body