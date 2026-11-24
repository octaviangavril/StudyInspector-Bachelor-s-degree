package com.StudyInspector.webAPI.controller;

import com.StudyInspector.application.model.Course;
import com.StudyInspector.application.model.user.CourseTeacher;
import com.StudyInspector.application.repository.CourseRepository;
import com.StudyInspector.application.repository.CourseTeacherRepository;
import com.StudyInspector.webAPI.dto.CourseDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import com.StudyInspector.webAPI.services.GoogleSpreadsheetsService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/course")
public class CourseController {
    private final CourseRepository courseRepository;
    private final CourseTeacherRepository courseTeacherRepository;
    private final GoogleSpreadsheetsService googleSpreadSheetsService;

    public CourseController(CourseRepository courseRepository, CourseTeacherRepository courseTeacherRepository, GoogleSpreadsheetsService googleSpreadSheetsService) {
        this.courseRepository = courseRepository;
        this.courseTeacherRepository = courseTeacherRepository;
        this.googleSpreadSheetsService = googleSpreadSheetsService;
    }

    @GetMapping("/getAllByCourseTeacher")
    public ResponseEntity<HttpResponseDto> getCourses(@RequestParam Long id) {
        CourseTeacher courseTeacher = courseTeacherRepository.findById(id).orElse(null);
        if (courseTeacher != null) {
            return new ResponseEntity<>(new HttpResponseDto(
                    "Courses found",
                    courseTeacher.getCourses()), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @PostMapping("/add")
    public ResponseEntity<HttpResponseDto> addCourse(@RequestParam Long id, @RequestBody CourseDto courseDto) {
        CourseTeacher courseTeacher = courseTeacherRepository.findById(id).orElse(null);

        if (courseTeacher != null) {
            if (courseDto.getCourseName() == null || courseDto.getUrlFileAllStudents() == null) {
                return new ResponseEntity<>(new HttpResponseDto("Invalid course data"),
                        HttpStatus.BAD_REQUEST);
            }
            if (courseTeacher.getCourses().stream().anyMatch(course -> course.getCourseName().equals(courseDto.getCourseName()))) {
                try {
                    googleSpreadSheetsService.deleteSpreadsheet(courseDto.getUrlFileAllStudents().substring(("https://docs.google.com/spreadsheets/d/").length()));
                } catch (IOException e) {
                    return new ResponseEntity<>(new HttpResponseDto("Error deleting spreadsheet: " + e.getMessage()),
                            HttpStatus.INTERNAL_SERVER_ERROR);
                }
                return new ResponseEntity<>(new HttpResponseDto("Course already exists"),
                        HttpStatus.BAD_REQUEST);
            }
            Course course = new Course();
            course.setCourseName(courseDto.getCourseName());
            course.setUrlFileAllStudents(courseDto.getUrlFileAllStudents());
            course.setPrivateUrlFileAllStudents(courseDto.getPrivateUrlFileAllStudents());
            course.setCourseTeacherId(courseTeacher.getId());
            course = courseRepository.save(course);

            return new ResponseEntity<>(new HttpResponseDto("Course added",
                    course), HttpStatus.OK);
        }

        return new ResponseEntity<>(new HttpResponseDto("Course Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getById")
    public ResponseEntity<HttpResponseDto> getCourseById(@RequestParam Long id) {
        Course course = courseRepository.findById(id).orElse(null);
        if (course != null) {
            return new ResponseEntity<>(new HttpResponseDto("Course found",
                    course), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }

    @PutMapping("/updateByTeacher")
    public ResponseEntity<HttpResponseDto> updateCourse(@RequestParam Long id, @RequestBody CourseDto courseDto) {
        Course course = courseRepository.findById(id).orElse(null);
        if (course != null) {
            if ((courseDto.getCourseName() == null || courseDto.getCourseName().isEmpty())
                    && (courseDto.getUrlFileAllStudents() == null || courseDto.getUrlFileAllStudents().isEmpty())) {
                return new ResponseEntity<>(new HttpResponseDto("Invalid course data"),
                        HttpStatus.BAD_REQUEST);
            }

            if (courseDto.getCourseName() != null && !courseDto.getCourseName().isEmpty())
                course.setCourseName(courseDto.getCourseName());
            if (courseDto.getUrlFileAllStudents() != null && !courseDto.getUrlFileAllStudents().isEmpty())
                course.setUrlFileAllStudents(courseDto.getUrlFileAllStudents());
            if (courseDto.getPrivateUrlFileAllStudents() != null && !courseDto.getPrivateUrlFileAllStudents().isEmpty())
                course.setPrivateUrlFileAllStudents(courseDto.getPrivateUrlFileAllStudents());

            courseRepository.save(course);
            return new ResponseEntity<>(new HttpResponseDto("Course updated successfully!",
                    course), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<HttpResponseDto> deleteCourse(@RequestParam Long id) {
        Course course = courseRepository.findById(id).orElse(null);
        if (course != null) {
            courseRepository.delete(course);
            return new ResponseEntity<>(new HttpResponseDto("Course deleted successfully!",
                    course), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getPrivateFile")
    public ResponseEntity<HttpResponseDto> getPrivateFile(@RequestParam Long courseId) {
        Course course = courseRepository.findById(courseId).orElse(null);
        if (course != null) {
            List<List<String>> privateSpreadsheet;
            try {
                privateSpreadsheet = googleSpreadSheetsService.getAllData(course.getPrivateUrlFileAllStudents().substring(("https://docs.google.com/spreadsheets/d/").length()));
            } catch (IOException e) {
                return new ResponseEntity<>(new HttpResponseDto("Error getting private spreadsheet: " + e.getMessage()),
                        HttpStatus.INTERNAL_SERVER_ERROR);
            }
            return new ResponseEntity<>(new HttpResponseDto("Course found",
                    privateSpreadsheet), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Course not found"),
                HttpStatus.NOT_FOUND);
    }
}