CREATE TABLE [Instructor]
(
    [Id] int NOT NULL IDENTITY,
    [FirstName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    [Email] nvarchar(max) NULL,
    CONSTRAINT [PK_Instructor] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Students]
(
    [Id] int NOT NULL IDENTITY,
    [FirstName] nvarchar(max) NULL,
    [MiddleName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    [DateOfBirth] datetime2 NULL,
    [Email] nvarchar(max) NULL,
    [EnrollmentDate] datetime2 NULL,
    CONSTRAINT [PK_Students] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Courses]
(
    [Id] int NOT NULL IDENTITY,
    [Title] nvarchar(max) NULL,
    [Credits] float NULL,
    [DecimalCredits] decimal(5,2) NULL,
    [InstructorId] int NULL,
    CONSTRAINT [PK_Courses] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Courses_Instructor_InstructorId] FOREIGN KEY ([InstructorId]) REFERENCES [Instructor] ([Id])
);
GO


CREATE TABLE [Department]
(
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NULL,
    [Budget] nvarchar(max) NULL,
    [StartDate] datetime2 NULL,
    [DepartmentHeadId] int NULL,
    CONSTRAINT [PK_Department] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Department_Instructor_DepartmentHeadId] FOREIGN KEY ([DepartmentHeadId]) REFERENCES [Instructor] ([Id])
);
GO


CREATE TABLE [Enrollments]
(
    [EnrollmentId] int NOT NULL IDENTITY,
    [StudentId] int NOT NULL,
    [CourseId] int NOT NULL,
    [FinalGrade] int NULL,
    CONSTRAINT [PK_Enrollments] PRIMARY KEY ([EnrollmentId]),
    CONSTRAINT [FK_Enrollments_Courses_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [Courses] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_Enrollments_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE
);
GO


CREATE UNIQUE INDEX [IX_Courses_InstructorId] ON [Courses] ([InstructorId]) WHERE [InstructorId] IS NOT NULL;
GO


CREATE UNIQUE INDEX [IX_Department_DepartmentHeadId] ON [Department] ([DepartmentHeadId]) WHERE [DepartmentHeadId] IS NOT NULL;
GO


CREATE UNIQUE INDEX [IX_Enrollments_CourseId] ON [Enrollments] ([CourseId]);
GO


CREATE UNIQUE INDEX [IX_Enrollments_StudentId] ON [Enrollments] ([StudentId]);
GO

-- Manually insert the query below to duplicate the data from the Credits column to the DecimalCredits column
BEGIN TRY
    BEGIN TRANSACTION;

    -- create a temporary table to store conversion errors
    CREATE TABLE #ConversionErrors
(
Id INT,
OriginalValue FLOAT,
ErrorMessage NVARCHAR(MAX)
);

    -- use a cursor to iterate over each row
    DECLARE @Id INT, @Credits FLOAT;

    DECLARE credits_cursor CURSOR FOR 
    SELECT Id, Credits
FROM Course;

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
            INSERT INTO #ConversionErrors
(Id, OriginalValue, ErrorMessage)
VALUES
(
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
    IF EXISTS (SELECT *
FROM #ConversionErrors)

    DROP TABLE #ConversionErrors;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW; -- re-throw the error
END CATCH
GO;