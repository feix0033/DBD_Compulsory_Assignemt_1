namespace StudentManagement;

public class Course
{
	public int Id { get; set; }
	public string? Title { get; set; }
	public double? Credits{ get; set; }
	public Enrollment? Enrollments { get; set; }
}
