IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [Courses] (
    [Id] int NOT NULL IDENTITY,
    [Title] nvarchar(max) NULL,
    [Credits] float NULL,
    CONSTRAINT [PK_Courses] PRIMARY KEY ([Id])
);

CREATE TABLE [Students] (
    [Id] int NOT NULL IDENTITY,
    [FirstName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    [Email] nvarchar(max) NULL,
    [EnrollmentDate] datetime2 NULL,
    CONSTRAINT [PK_Students] PRIMARY KEY ([Id])
);

CREATE TABLE [Enrollments] (
    [EnrollmentId] int NOT NULL IDENTITY,
    [StudentId] int NOT NULL,
    [CourseId] int NOT NULL,
    [Grade] int NULL,
    CONSTRAINT [PK_Enrollments] PRIMARY KEY ([EnrollmentId]),
    CONSTRAINT [FK_Enrollments_Courses_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [Courses] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_Enrollments_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE
);

CREATE UNIQUE INDEX [IX_Enrollments_CourseId] ON [Enrollments] ([CourseId]);

CREATE UNIQUE INDEX [IX_Enrollments_StudentId] ON [Enrollments] ([StudentId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308110523_V1__InitialSchema.sql', N'9.0.2');

ALTER TABLE [Students] ADD [MiddleName] nvarchar(max) NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308115654_V2__AddMiddleNameToStudent.sql', N'9.0.2');

ALTER TABLE [Students] ADD [DateOfBirth] datetime2 NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308120257_V3__AddDateOfBirthToStudent.sql', N'9.0.2');

ALTER TABLE [Courses] ADD [InstructorId] int NULL;

CREATE TABLE [Instructor] (
    [Id] int NOT NULL IDENTITY,
    [FirstName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    [Email] nvarchar(max) NULL,
    CONSTRAINT [PK_Instructor] PRIMARY KEY ([Id])
);

CREATE UNIQUE INDEX [IX_Courses_InstructorId] ON [Courses] ([InstructorId]) WHERE [InstructorId] IS NOT NULL;

ALTER TABLE [Courses] ADD CONSTRAINT [FK_Courses_Instructor_InstructorId] FOREIGN KEY ([InstructorId]) REFERENCES [Instructor] ([Id]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308121425_V4__AddInstructorRelation.sql', N'9.0.2');

EXEC sp_rename N'[Enrollments].[Grade]', N'FinalGrade', 'COLUMN';

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308124227_V5__RenameGradeAttributeToFinalGradeInEnrollment.sql', N'9.0.2');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308131025_V6__AddDepartmentRelation.sql', N'9.0.2');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308131320_V6_2__AddDepartmentRelation.sql', N'9.0.2');

ALTER TABLE [Courses] ADD [DecimalCredits] decimal(5,2) NULL;


                BEGIN TRY
                    BEGIN TRANSACTION;

                    -- create a temporary table to store conversion errors
                    CREATE TABLE #ConversionErrors (
                        Id INT,
                        OriginalValue FLOAT,
                        ErrorMessage NVARCHAR(MAX)
                    );

                    -- use a cursor to iterate over each row
                    DECLARE @Id INT, @Credits FLOAT;

                    DECLARE credits_cursor CURSOR FOR 
                    SELECT Id, Credits FROM Course;

                    OPEN credits_cursor;
                    FETCH NEXT FROM credits_cursor INTO  @Id, @Credits;

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        BEGIN TRY
                            -- try to convert the value
                            UPDATE Course 
                            SET DecimalCredits = 
                                CASE 
                                    WHEN ROUND(@Credits, 2) > 999.99 THEN 999.99
                                    WHEN ROUND(@Credits, 2) < -999.99 THEN -999.99
                                    ELSE TRY_CAST(ROUND(@Credits, 2) AS DECIMAL(5,2))
                                END
                            WHERE Id = @Id;
                        END TRY
                        BEGIN CATCH
                            -- log the error
                            INSERT INTO #ConversionErrors (Id, OriginalValue, ErrorMessage)
                            VALUES (
                                @Id,
                                @Credits,
                                'Error: ' + ERROR_MESSAGE() + 
                                ' | Code: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
                            );
                        END CATCH

                        FETCH NEXT FROM credits_cursor INTO @Id, @Credits;
                    END

                    CLOSE credits_cursor;
                    DEALLOCATE credits_cursor;

                    -- check for errors
                    IF EXISTS (SELECT * FROM #ConversionErrors)

                    DROP TABLE #ConversionErrors;

                    COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                    IF @@TRANCOUNT > 0
                        ROLLBACK TRANSACTION;

                    THROW; -- re-throw the error
                END CATCH
            

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308141440_V7_1__ModifyCourseCredits_AddDecimalCredits.sql', N'9.0.2');

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308145121_V7_2__ManullyModifyMigrationFileToHandleMigrationOldValueToNew.sql', N'9.0.2');

DECLARE @var sysname;
SELECT @var = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Courses]') AND [c].[name] = N'Credits');
IF @var IS NOT NULL EXEC(N'ALTER TABLE [Courses] DROP CONSTRAINT [' + @var + '];');
ALTER TABLE [Courses] DROP COLUMN [Credits];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250308145653_V7_3__RemoveCreditsAttributes.sql', N'9.0.2');

COMMIT;
GO

