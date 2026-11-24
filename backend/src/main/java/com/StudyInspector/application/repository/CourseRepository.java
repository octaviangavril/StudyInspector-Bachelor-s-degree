package com.StudyInspector.application.repository;

import com.StudyInspector.application.model.Course;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface CourseRepository extends CrudRepository<Course, Long> {
    @Query("SELECT c FROM Course c WHERE c.courseName = ?1")
    Course findByName(String name);
}
