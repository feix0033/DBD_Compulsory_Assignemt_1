namespace StudentManagement;

public class Course
{
	public int Id { get; set; }
	public string? Title { get; set; }
	// public double? Credits{ get; set; }
	public decimal? DecimalCredits{ get; set; }
	public int? InstructorId { get; set; }
	public Enrollment? Enrollments { get; set; }
	public Instructor? Instructor { get; set; }
}
