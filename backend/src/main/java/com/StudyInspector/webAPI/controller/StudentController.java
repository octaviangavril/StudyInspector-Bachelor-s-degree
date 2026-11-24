package com.StudyInspector.webAPI.controller;

import com.StudyInspector.application.model.Group;
import com.StudyInspector.application.model.Student;
import com.StudyInspector.application.repository.GroupRepository;
import com.StudyInspector.application.repository.StudentRepository;
import com.StudyInspector.webAPI.dto.StudentDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/student")
public class StudentController {
    private final StudentRepository studentRepository;
    private final GroupRepository groupRepository;

    public StudentController(StudentRepository studentRepository, GroupRepository groupRepository) {
        this.studentRepository = studentRepository;
        this.groupRepository = groupRepository;
    }

    @PostMapping("/add")
    public ResponseEntity<HttpResponseDto> addStudent(@RequestBody StudentDto studentDto) {
        Group group = groupRepository.findById(studentDto.getGroupId()).orElse(null);

        if (group != null) {
            if ((studentDto.getMatriculationNumber() == null || studentDto.getMatriculationNumber().isEmpty())
                    || (studentDto.getFirstName() == null || studentDto.getFirstName().isEmpty()
                    || (studentDto.getLastName() == null || studentDto.getLastName().isEmpty()))
                    || (studentDto.getEmail() == null || studentDto.getEmail().isEmpty())
                    || (studentDto.getPhoneNumber() == null || studentDto.getPhoneNumber().isEmpty())) {

                return new ResponseEntity<>(new HttpResponseDto("Invalid student data"),
                        HttpStatus.BAD_REQUEST);
            }
            if (group.getStudents().stream().anyMatch(student -> student.getMatriculationNumber()
                    .equals(studentDto.getMatriculationNumber()))){
                return new ResponseEntity<>(new HttpResponseDto("Student already exists"),
                        HttpStatus.BAD_REQUEST);
            }
            Student student = new Student();
            student.setFirstName(studentDto.getFirstName());
            student.setLastName(studentDto.getLastName());
            student.setEmail(studentDto.getEmail());
            student.setPhoneNumber(studentDto.getPhoneNumber());
            student.setMatriculationNumber(studentDto.getMatriculationNumber());
            student.setGroupId(group.getId());

            studentRepository.save(student);

            return new ResponseEntity<>(new HttpResponseDto("Student created successfully!",
                    student), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Group not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/all")
    public ResponseEntity<HttpResponseDto> getAllStudents() {
        return new ResponseEntity<>(new HttpResponseDto("Students found",
                studentRepository.findAll()), HttpStatus.OK);
    }

    @GetMapping("/getByMatriculationNumber")
    public ResponseEntity<HttpResponseDto> getStudentByMatriculationNumber(@RequestParam String matriculationNumber) {
        Student student = studentRepository.findByMatriculationNumber(matriculationNumber);
        if (student != null) {
            return new ResponseEntity<>(new HttpResponseDto("Student found",
                    student), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Student not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getAllByGroup")
    public ResponseEntity<HttpResponseDto> getStudentsByGroup(@RequestParam Long id) {
        Group group = groupRepository.findById(id).orElse(null);
        if (group != null) {
            return new ResponseEntity<>(new HttpResponseDto("Students found",
                    group.getStudents()), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Group not found"),
                HttpStatus.NOT_FOUND);
    }

    @PutMapping("/update")
    public ResponseEntity<HttpResponseDto> updateStudent(@RequestParam Long id, @RequestBody StudentDto studentDto) {
        Student student = studentRepository.findById(id).orElse(null);
        if (student != null) {
            if (studentDto.getMatriculationNumber() != null && !studentDto.getMatriculationNumber().isEmpty()) {
                student.setMatriculationNumber(studentDto.getMatriculationNumber());
            }
            if (studentDto.getFirstName() != null && !studentDto.getFirstName().isEmpty()) {
                student.setFirstName(studentDto.getFirstName());
            }
            if (studentDto.getLastName() != null && !studentDto.getLastName().isEmpty()) {
                student.setLastName(studentDto.getLastName());
            }
            if (studentDto.getEmail() != null && !studentDto.getEmail().isEmpty()) {
                student.setEmail(studentDto.getEmail());
            }
            if (studentDto.getPhoneNumber() != null && !studentDto.getPhoneNumber().isEmpty()) {
                student.setPhoneNumber(studentDto.getPhoneNumber());
            }
            if (studentDto.getGroupId() != null && studentDto.getGroupId() != 0) {
                Group group = groupRepository.findById(studentDto.getGroupId()).orElse(null);
                if (group != null) {
                    student.setGroupId(group.getId());

                    List<Student> students = group.getStudents();
                    students.add(student);
                    group.setStudents(students);
                    groupRepository.save(group);
                }
                else {
                    return new ResponseEntity<>(new HttpResponseDto("Group not found"),
                            HttpStatus.NOT_FOUND);
                }
            }
            studentRepository.save(student);
            return new ResponseEntity<>(new HttpResponseDto("Student updated successfully",
                    student), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Student not found"), HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<HttpResponseDto> deleteStudent(@RequestParam Long id) {
        Student student = studentRepository.findById(id).orElse(null);
        if (student != null) {
            studentRepository.delete(student);
            return new ResponseEntity<>(new HttpResponseDto("Student deleted successfully!",
                    student), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Student not found"),
                HttpStatus.NOT_FOUND);
    }
}
