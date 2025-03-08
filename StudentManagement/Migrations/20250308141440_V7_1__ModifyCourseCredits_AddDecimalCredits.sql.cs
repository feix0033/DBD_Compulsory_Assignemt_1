using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StudentManagement.Migrations
{
    /// <inheritdoc />
    public partial class V7_1__ModifyCourseCredits_AddDecimalCreditssql : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "DecimalCredits",
                table: "Courses",
                type: "decimal(5,2)",
                precision: 5,
                scale: 2,
                nullable: true);
            // migrationBuilder.Sql("UPDATE Course SET DecimalCredits = Credits;");
            migrationBuilder.Sql(@"
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
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DecimalCredits",
                table: "Courses");
        }
    }
}
