package com.StudyInspector.webAPI.controller;

import com.StudyInspector.application.model.Course;
import com.StudyInspector.application.model.Group;
import com.StudyInspector.application.model.user.LabTeacher;
import com.StudyInspector.application.model.Student;
import com.StudyInspector.application.repository.CourseRepository;
import com.StudyInspector.application.repository.GroupRepository;
import com.StudyInspector.application.repository.LabTeacherRepository;
import com.StudyInspector.application.repository.StudentRepository;
import com.StudyInspector.webAPI.dto.GroupDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import com.StudyInspector.webAPI.services.GoogleSpreadsheetsService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/group")
public class GroupController {
    private final GroupRepository groupRepository;
    private final LabTeacherRepository labTeacherRepository;
    private final CourseRepository courseRepository;
    private final GoogleSpreadsheetsService googleSpreadSheetsService;
    private final StudentRepository studentRepository;

    public GroupController(GroupRepository groupRepository, LabTeacherRepository labTeacherRepository, CourseRepository courseRepository, GoogleSpreadsheetsService googleSpreadSheetsService, StudentRepository studentRepository) {
        this.groupRepository = groupRepository;
        this.labTeacherRepository = labTeacherRepository;
        this.courseRepository = courseRepository;
        this.googleSpreadSheetsService = googleSpreadSheetsService;
        this.studentRepository = studentRepository;
    }

    @GetMapping("/all")
    public ResponseEntity<HttpResponseDto> getAllGroups() {
        return new ResponseEntity<>(new HttpResponseDto("Groups found",
                groupRepository.findAll()), HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<HttpResponseDto> addGroup(@RequestParam Long teacherId, @RequestParam Long courseId, @RequestBody GroupDto groupDto) {
        LabTeacher labTeacher = labTeacherRepository.findById(teacherId).orElse(null);
        Course course = courseRepository.findById(courseId).orElse(null);

        if (labTeacher != null && course != null) {
            if ((groupDto.getGroupName() == null || groupDto.getGroupName().isEmpty())) {

                return new ResponseEntity<>(new HttpResponseDto("Invalid group data"),
                        HttpStatus.BAD_REQUEST);
            }
            if (course.getGroups().stream().anyMatch(group -> group.getGroupName().equals(groupDto.getGroupName()))) {
                return new ResponseEntity<>(new HttpResponseDto("Group already exists"),
                        HttpStatus.BAD_REQUEST);
            }
            Group group = new Group();
            group.setGroupName(groupDto.getGroupName());
            group.setLabTeacherId(teacherId);
            group.setCourseId(courseId);

            group = groupRepository.save(group);

            return new ResponseEntity<>(new HttpResponseDto("Group added",
                    group), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course or Lab Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getById")
    public ResponseEntity<HttpResponseDto> getGroupById(@RequestParam Long id) {
        Group group = groupRepository.findById(id).orElse(null);
        if (group != null) {
            return new ResponseEntity<>(new HttpResponseDto("Group found",
                    group), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Group not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getAllByLabTeacher")
    public ResponseEntity<HttpResponseDto> getGroupByLabTeacher(@RequestParam Long id) {
       LabTeacher labTeacher = labTeacherRepository.findById(id).orElse(null);
        if (labTeacher != null) {
            return new ResponseEntity<>(new HttpResponseDto("Groups found",
                    labTeacher.getGroups()), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Lab Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getAllByCourse")
    public ResponseEntity<HttpResponseDto> getGroupByCourse(@RequestParam Long id) {
        Course course = courseRepository.findById(id).orElse(null);
        if (course != null) {
            return new ResponseEntity<>(new HttpResponseDto("Groups found",
                    course.getGroups()), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<HttpResponseDto> deleteGroup(@RequestParam Long id) {
        Group group = groupRepository.findById(id).orElse(null);
        if (group != null) {
            groupRepository.delete(group);
            return new ResponseEntity<>(new HttpResponseDto("Group deleted",
                    group), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Group not found"),
                HttpStatus.NOT_FOUND);
    }

    @PutMapping("/updateLabGrade")
    public ResponseEntity<HttpResponseDto> updateLabGrade(@RequestParam Long courseId, @RequestParam String matriculationNumber, @RequestParam String labName, @RequestParam Double grade) {
        Course course = courseRepository.findById(courseId).orElse(null);

        if (course != null) {
            try {
                String spreadsheetId = course.getUrlFileAllStudents().substring(("https://docs.google.com/spreadsheets/d/").length());
                googleSpreadSheetsService.updateCellValue(spreadsheetId, matriculationNumber, labName, grade.toString());
            } catch (IOException e) {
                return new ResponseEntity<>(new HttpResponseDto("Error updating lab grade: " + e.getMessage()),
                        HttpStatus.INTERNAL_SERVER_ERROR);
            }
            return new ResponseEntity<>(new HttpResponseDto("Lab grade updated"),
                    HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }

    @PutMapping("/removeStudent")
    public ResponseEntity<HttpResponseDto> removeStudent(@RequestParam Long groupId, @RequestParam Long studentId) {
        Group group = groupRepository.findById(groupId).orElse(null);
        Student student = studentRepository.findById(studentId).orElse(null);
        if (group != null && student != null) {
            List<Student> students = group.getStudents();
            students.remove(student);
            group.setStudents(students);
            groupRepository.save(group);
            return new ResponseEntity<>(new HttpResponseDto("Student removed",
                    group), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Group or student not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getStudentsTable")
    public ResponseEntity<HttpResponseDto> getStudentsTable(@RequestParam Long courseId, @RequestParam List<String> studentsMatriculationNumbers) {
        Course course = courseRepository.findById(courseId).orElse(null);
        if (course != null) {
            try {
                String spreadsheetId = course.getPrivateUrlFileAllStudents().substring(("https://docs.google.com/spreadsheets/d/").length());
                return new ResponseEntity<>(new HttpResponseDto("Student table found",
                        googleSpreadSheetsService.getStudentsTable(spreadsheetId, studentsMatriculationNumbers)), HttpStatus.OK);
            } catch (IOException e) {
                return new ResponseEntity<>(new HttpResponseDto("Error getting student table: " + e.getMessage()),
                        HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }
}
