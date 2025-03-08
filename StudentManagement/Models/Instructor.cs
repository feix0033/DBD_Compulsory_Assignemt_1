﻿namespace StudentManagement;

public class Instructor
{
	public int Id { get; set; }
	public string? FirstName { get; set; }
	public string? LastName { get; set; }
	public string? Email { get; set; }
	public Course? Courses { get; set; }
	public Department? Department { get; set; }
}
