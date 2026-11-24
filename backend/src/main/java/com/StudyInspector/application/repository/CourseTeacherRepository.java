package com.StudyInspector.application.repository;

import com.StudyInspector.application.model.user.CourseTeacher;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface CourseTeacherRepository extends CrudRepository<CourseTeacher, Long>{
    @Query("SELECT c FROM CourseTeacher c WHERE c.email = ?1")
    CourseTeacher findByEmail(String email);
}
