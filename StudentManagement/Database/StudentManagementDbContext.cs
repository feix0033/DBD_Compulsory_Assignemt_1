namespace StudentManagement.Database;
using Microsoft.EntityFrameworkCore;

public class StudentMangementDbContext : DbContext
{
	public DbSet<Student> Students { get; set; }
	public DbSet<Course> Courses { get; set; }
	public DbSet<Enrollment> Enrollments { get; set; }

	protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
	{
		optionsBuilder.UseSqlServer("Server=localhost;Database=StudentManagement;uid=sa;password=YourStrong@Passw0rd;Encrypt=false;TrustServerCertificate=True");
	}

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.Entity<Enrollment>()
			.HasOne(e => e.Student)
			.WithOne(s => s.Enrollments)
			.HasForeignKey<Enrollment>(e => e.StudentId);

		modelBuilder.Entity<Enrollment>()
			.HasOne(e => e.Course)
			.WithOne(c => c.Enrollments)
			.HasForeignKey<Enrollment>(e => e.CourseId);
		modelBuilder.Entity<Course>()
			.HasOne(c => c.Instructor)
			.WithOne(i => i.Courses)
			.HasForeignKey<Course>(c => c.InstructorId);
		modelBuilder.Entity<Department>()
			.HasOne(d => d.DepartmentHead)
			.WithOne(i => i.Department)
			.HasForeignKey<Department>(d => d.DepartmentHeadId);
	}
}
