package com.StudyInspector.application.model.user;

import com.StudyInspector.application.model.Group;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;
@EqualsAndHashCode(callSuper = true)
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@Table(name = "lab_teachers")
@Data
@NoArgsConstructor
public class LabTeacher extends UserEntity{
    @OneToMany(mappedBy = "labTeacherId", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<Group> groups = new ArrayList<>();
}
