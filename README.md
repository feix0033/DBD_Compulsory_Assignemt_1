# Student Management

## Init solution and project

- `dotnet new sln` init solution.
- `dotnet new console -o StudentMangement` init console application and set the output directory as StudentMangement.
- `dotnet sln add StudentManagement/StudentManagement.csproj` add project referrence to solution.
- add git ignore file, using the [dotnet gitignore template](https://github.com/github/gitignore)

### Dotnet add packages

- `cd StudentManagement` access into project.
- `dotnet add package Microsoft.EntityFrameworkCore --version 9.0.2` EF core package
- `dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 9.0.2` EF SQL Server helper
- `dotnet add package Microsoft.EntityFrameworkCore.Design --version 9.0.2` EF DB Developing pacakge

### Build the projcet to test it can be work

- In the project: `dotnet run` build and excute the project.
  - Should show the 'Hello World!' in console.
- Alternativly, in VSCode.
  - Click 'Run and Debug' icon.
  - Choose 'Creat launch.json'
  - Choose correct language and project.
  - Click 'Run and Debug' button.
  - Should show 'Hello World' in debug console.

## Create the feature branch EF Code-First

- `git checkout -b feat/initial-schema-ef`

### Creat Entities in Models directory

- `dotnet new class -n Student -o Models`.
- `dotnet new class -n Course -o Models`.
- `dotnet new class -n Enrollment -o Models`.

### Define the Attributes for entities

- see: [Student.cs](./StudentManagement/Models/Student.cs)
- see: [Course.cs](./StudentManagement/Models/Course.cs)
- see: [Enrollment.cs](./StudentManagement/Models/Enrollment.cs)

### Define the DbContext in Database directory

- `dotnet new class -n StudentMangementDbContext -o Database`
- see: [StudentMangement](./StudentManagement/Database/StudentMangementDbContext.cs)

### Define the primary and foreign keys

- In EF Core the primary key will auto detect by [*Id] attribute name.
- For adding the foreign keys:
  - Using fluentAPI, See: `StudentMangement.cs`, `onModelCrating()` override method.
  - Add the reference Object in the Enrollment, Student and Course.
