package com.StudyInspector.application.repository;

import com.StudyInspector.application.model.user.LabTeacher;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface LabTeacherRepository extends CrudRepository<LabTeacher, Long> {
    @Query("SELECT c FROM LabTeacher c WHERE c.email = ?1")
    LabTeacher findByEmail(String email);
}
