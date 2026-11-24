package com.StudyInspector.webAPI.controller;

import com.StudyInspector.application.model.user.LabTeacher;
import com.StudyInspector.application.repository.LabTeacherRepository;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/labTeacher")
public class LabTeacherController {
    private final LabTeacherRepository labTeacherRepository;

    public LabTeacherController(LabTeacherRepository labTeacherRepository) {
        this.labTeacherRepository = labTeacherRepository;
    }

    @GetMapping("/all")
    public ResponseEntity<HttpResponseDto> getAllTeachers() {
        return new ResponseEntity<>(new HttpResponseDto("Lab Teachers found",
                labTeacherRepository.findAll()), HttpStatus.OK);
    }

    @GetMapping("/get")
    public ResponseEntity<HttpResponseDto> getTeacherByEmail(@RequestParam String email) {
        LabTeacher labTeacher = labTeacherRepository.findByEmail(email);
        if (labTeacher != null) {
            return new ResponseEntity<>(new HttpResponseDto("Lab Teacher found",
                    labTeacher), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getById")
    public ResponseEntity<?> getTeacherById(@RequestParam Long id) {
        LabTeacher labTeacher = labTeacherRepository.findById(id).orElse(null);
        if (labTeacher != null) {
            return new ResponseEntity<>(new HttpResponseDto("Lab Teacher found",
                    labTeacher), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Teacher not found"),
                HttpStatus.NOT_FOUND);
    }
}
