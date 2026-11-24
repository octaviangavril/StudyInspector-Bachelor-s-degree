package com.StudyInspector.application.repository;

import com.StudyInspector.application.model.Group;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

public interface GroupRepository extends CrudRepository<Group, Long> {
    @Query("SELECT g FROM Group g WHERE g.groupName = ?1")
    Group findByName(String name);
}
