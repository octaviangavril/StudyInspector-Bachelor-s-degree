package com.StudyInspector.application.model.user;

import com.StudyInspector.application.model.Course;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@EqualsAndHashCode(callSuper = true)
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@Table(name = "course_teachers")
@Data
@NoArgsConstructor
public class CourseTeacher extends LabTeacher{
    @OneToMany(mappedBy = "courseTeacherId", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<Course> courses = new ArrayList<>();

    @JsonManagedReference
    public List<Course> getCourses() {
        return courses;
    }
}
