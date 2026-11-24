package com.StudyInspector.application.repository;

import com.StudyInspector.application.model.Student;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface StudentRepository extends CrudRepository<Student, Long> {
    @Query("SELECT s FROM Student s WHERE s.matriculationNumber = ?1")
    Student findByMatriculationNumber(String matriculationNumber);
}
