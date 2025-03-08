CREATE TABLE [Courses] (
    [Id] int NOT NULL IDENTITY,
    [Title] nvarchar(max) NULL,
    [Credits] float NULL,
    CONSTRAINT [PK_Courses] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Students] (
    [Id] int NOT NULL IDENTITY,
    [FirstName] nvarchar(max) NULL,
    [LastName] nvarchar(max) NULL,
    [MiddleName] nvarchar(max) NULL, -- New column
    [Email] nvarchar(max) NULL,
    [EnrollmentDate] datetime2 NULL,
    CONSTRAINT [PK_Students] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Enrollments] (
    [EnrollmentId] int NOT NULL IDENTITY,
    [StudentId] int NOT NULL,
    [CourseId] int NOT NULL,
    [Grade] int NULL,
    CONSTRAINT [PK_Enrollments] PRIMARY KEY ([EnrollmentId]),
    CONSTRAINT [FK_Enrollments_Courses_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [Courses] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_Enrollments_Students_StudentId] FOREIGN KEY ([StudentId]) REFERENCES [Students] ([Id]) ON DELETE CASCADE
);
GO


CREATE UNIQUE INDEX [IX_Enrollments_CourseId] ON [Enrollments] ([CourseId]);
GO


CREATE UNIQUE INDEX [IX_Enrollments_StudentId] ON [Enrollments] ([StudentId]);
GO


