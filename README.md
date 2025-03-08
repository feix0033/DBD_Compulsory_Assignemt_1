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

***

## 1. Init Schema

### Create the feature branch EF Code-First

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

### Generate migrations

- `dotnet ef migrations add V1__InitialSchema.sql --context StudentManagement.Database.StudentMangementDbContext` generate the init schema migrations and asign the context.
- `dotnet ef migrations script -o SqlScriptEf/V1__InitialSchemaEF.sql --context StudentManagement.Database.StudentMangementDbContext` generate the db migration script for prod env.
  - Notice: The default `migrations script` will not create the database instence.
  - If the database was not be create, then need to manully create. (Auto create the database in prod env is bed practice.)
    - `sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "CREATE DATABASE StudentManagement"`
  - Test implementing the script artifact, use the mssql cli locally.
    - `sqlcmd -S localhost -d StudentManagement -U sa -P YourStrong@Passw0rd -i ./StudentManagement/SqlScriptEf/InitialSchemaEF.sql`.
- Test migrations artifact, need remove the database then excute following:
  - `dotnet ef database update`.

## 2. Add MiddleName to Student

- `git checkout -b feat/add-middle-name-to-student-ef`.
- Add the `middleName` attribute in `Student`.
- generate the migrations.
- generate the migrations artifact.

## 3. Add DateOfBirth to Student

- `git checkout -b feat/add-date-of-birth-to-student-ef`
- Add the `DateOfBirth` attribute in `Student`
- generate the migrations.
- generate the migrations artifact.

## 4. Add Instructor relation

- `git checkout -b feat/add-instruction-relation-ef`
- Create `Instructor` in `Models`.
- Add the `InstructorId` attribute in `Course` and add the reference.
- generate the migrations.
- generate the migrations artifact.

## 5. Rename Grade attribute to FinalGrade in Enrollment

- `git checkout -b feat/rename-grade-attribute-to-final-grade-in-enrollment-ef`

### Destructive vs non-destructive approach

The Destructive approach for change the database schema means directly change the schema.
The approach broke the data consistency and integrity.

For example:

- Directly change the attribute name maybe will cause the data loss or application break down because the ord attribute and not be found.

In this case, I will use destructive approach, the reason following:

- Now we are in the inital development stage. The enviroment is development enviroment.
- There are no data in the database.
- The `Grade` attribute has no reference and dependence with others.
- I want do an example for destructive approach in this case.

### Use Destructive approach rename

- Directly modify the `Grade` attribute in `Enrollment`.
- generate the migrations.
- generate the migrations artifact.

## 6. Add Department relation

- `git checkout -b feat/add-department-relation-ef`
- Create `Department` in `Models`.
- Add the `DepartmentHead` attribute in `Department` and add the reference.
- generate the migrations.
- generate the migrations artifact.

## 7. Modify the Course Credits relation

- `git checkout -b feat/modify-course-credits-relation-ef`

### Use non-Destructive approach modify the attribute type

In this case, because we need modify the `Credits` data type in the `Course`.
The the non-destructive approach will cause the ord data can not fit with the new data type.
Previously, we use the double data type, that was instore in the Database as float.
The float default digitals is 53 digitals which maybe over the dicimal(5,2).
And if we have data like 123.456, it will not fit with the dicimal(5,2). (The 0.06 will loss).
So we have to handle the situation by using non-destructive approach.

### The approch of non-destrctive

1. Add new attribute `decimalCredits` instead direct change the old attribute `Credits`.
2. Update the CRUD code to make sure the operation will be using for both old and new attributes.
    This step will skiped since we didn't implement the CRUD.
3. Manully modify the migration file to duplicate the data to the new attribute.
4. Remove the old attribute. (This step will happend after the data consistence and integraty was be checked.)
5. Generate migration script.