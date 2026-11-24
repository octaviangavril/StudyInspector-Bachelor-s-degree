package com.StudyInspector.webAPI.controller;

import com.StudyInspector.application.model.Course;
import com.StudyInspector.application.model.Group;
import com.StudyInspector.application.model.user.CourseTeacher;
import com.StudyInspector.application.repository.CourseTeacherRepository;
import com.StudyInspector.webAPI.dto.CourseDataDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import com.StudyInspector.webAPI.services.CourseEntitiesDataService;
import com.StudyInspector.webAPI.services.GoogleSpreadsheetsService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/courseTeacher")
public class CourseTeacherController {

    private final CourseTeacherRepository courseTeacherRepository;
    private final GoogleSpreadsheetsService googleSpreadSheetsService;
    private final CourseEntitiesDataService courseEntitiesDataService;

    public CourseTeacherController(CourseTeacherRepository courseTeacherRepository,
                                   GoogleSpreadsheetsService googleSpreadSheetsService, CourseEntitiesDataService courseEntitiesDataService) {
        this.courseTeacherRepository = courseTeacherRepository;
        this.googleSpreadSheetsService = googleSpreadSheetsService;
        this.courseEntitiesDataService = courseEntitiesDataService;
    }

    @GetMapping("/all")
    public ResponseEntity<HttpResponseDto> getAllTeachers() {
        return new ResponseEntity<>(new HttpResponseDto("Course Teachers found",
                courseTeacherRepository.findAll()), HttpStatus.OK);
    }

    @GetMapping("/get")
    public ResponseEntity<HttpResponseDto> getTeacherByEmail(@RequestParam String email) {
        CourseTeacher courseTeacher = courseTeacherRepository.findByEmail(email);
        if (courseTeacher != null) {
            return new ResponseEntity<>(new HttpResponseDto("Course Teacher found",
                    courseTeacherRepository.findAll()), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getById")
    public ResponseEntity<HttpResponseDto> getTeacherById(@RequestParam Long id) {
        CourseTeacher courseTeacher = courseTeacherRepository.findById(id).orElse(null);
        if (courseTeacher != null) {
            return new ResponseEntity<>(new HttpResponseDto("Course Teacher found",
                    courseTeacher), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("Teacher not found"),
                HttpStatus.NOT_FOUND);
    }

    @PostMapping("/createCourseEntities")
    public ResponseEntity<HttpResponseDto> createCourseEntities(
            @RequestHeader("Authorization") String authorizationToken,
            @RequestParam Long id,
            @RequestBody CourseDataDto courseDataDto) {

        authorizationToken = authorizationToken.substring(7);

        List<String> columns = new ArrayList<>(List.of("An", "Grupa", "Numar matricol", "Nume", "Prenume"));
        columns.addAll(courseDataDto.getSpreadsheetTemplateColumns());
        columns.add("Total");

        try {
            String coursePrivateSpreadsheetId = googleSpreadSheetsService.generateMySpreadsheet(courseDataDto.getCourseName(), columns, courseDataDto.getStudentsData().get("An").size(), true);
            String courseSpreadsheetId = googleSpreadSheetsService.generateMySpreadsheet(courseDataDto.getCourseName() + " GDPR", columns.stream().filter(columnName ->
                    !Objects.equals(columnName, "Nume") && !Objects.equals(columnName, "Prenume")).toList(), courseDataDto.getStudentsData().get("An").size(), false);
            googleSpreadSheetsService.populateColumn(courseSpreadsheetId, "Numar matricol", courseDataDto.getStudentsData().get("Numar matricol"));
            googleSpreadSheetsService.populateColumn(coursePrivateSpreadsheetId, "Nume", courseDataDto.getStudentsData().get("Nume"));
            googleSpreadSheetsService.populateColumn(coursePrivateSpreadsheetId, "Prenume", courseDataDto.getStudentsData().get("Prenume"));
            googleSpreadSheetsService.importRange(courseSpreadsheetId, coursePrivateSpreadsheetId);

            googleSpreadSheetsService.populateColumn(courseSpreadsheetId, "An", courseDataDto.getStudentsData().get("An"));
            googleSpreadSheetsService.populateColumn(courseSpreadsheetId, "Grupa", courseDataDto.getStudentsData().get("Grupa"));

            ResponseEntity<HttpResponseDto> response = courseEntitiesDataService.createCourse(authorizationToken, id, courseDataDto.getCourseName(), "https://docs.google.com/spreadsheets/d/" + courseSpreadsheetId, "https://docs.google.com/spreadsheets/d/" + coursePrivateSpreadsheetId);

            if (response.getStatusCode() != HttpStatus.OK) {
                return new ResponseEntity<>(response.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
            }

            ObjectMapper objectMapper = new ObjectMapper();
            Long courseId = objectMapper.convertValue(Objects.requireNonNull(response.getBody()).getPayload(), Course.class).getId();

            for (String groupName : courseDataDto.getLabTeachersIds().keySet()){
                List<Integer> groupStudentsIndexes = new ArrayList<>();
                int i = 0;
                while(i < courseDataDto.getStudentsData().get("Grupa").size()){
                    if (courseDataDto.getStudentsData().get("Grupa").get(i).equals(groupName)){
                        groupStudentsIndexes.add(i);
                    }
                    i++;
                }

                Long labTeacherId = courseDataDto.getLabTeachersIds().get(groupName);

                ResponseEntity<HttpResponseDto> groupResponse = courseEntitiesDataService.createGroup(authorizationToken, labTeacherId, courseId, courseDataDto.getCourseName() + "-" + groupName);

                if (groupResponse.getStatusCode() != HttpStatus.OK) {
                    return new ResponseEntity<>(groupResponse.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
                }

                Long groupId = objectMapper.convertValue(Objects.requireNonNull(groupResponse.getBody()).getPayload(), Group.class).getId();

                for (Integer groupStudentsIndex : groupStudentsIndexes) {
                    String firstName = courseDataDto.getStudentsData().get("Prenume").get(groupStudentsIndex);
                    String lastName = courseDataDto.getStudentsData().get("Nume").get(groupStudentsIndex);
                    String email = courseDataDto.getStudentsData().get("Email").get(groupStudentsIndex);
                    String phoneNumber = courseDataDto.getStudentsData().get("Numar de telefon").get(groupStudentsIndex);
                    String matriculationNumber = courseDataDto.getStudentsData().get("Numar matricol").get(groupStudentsIndex);

                    ResponseEntity<HttpResponseDto> studentResponse = courseEntitiesDataService.createStudent(authorizationToken,
                            firstName, lastName, email, phoneNumber, matriculationNumber, groupId);

                    if (studentResponse.getStatusCode() != HttpStatus.OK) {
                        return new ResponseEntity<>(studentResponse.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
                    }
                }
            }

        } catch (Exception e) {
            return new ResponseEntity<>(new HttpResponseDto("A apărut o eroare la crearea foii de calcul: " + e.getMessage()),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>(new HttpResponseDto("Cererea a fost procesată cu succes"),
                HttpStatus.OK);
    }

    @DeleteMapping("/deleteCourseEntities")
    public ResponseEntity<HttpResponseDto> deleteCourseEntities(
            @RequestHeader("Authorization") String authorizationToken,
            @RequestParam Long id) {

        authorizationToken = authorizationToken.substring(7);
        ResponseEntity<HttpResponseDto> response = courseEntitiesDataService.deleteCourse(authorizationToken, id);
        if (response.getStatusCode() != HttpStatus.OK) {
            return new ResponseEntity<>(response.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>(new HttpResponseDto("Cererea a fost procesată cu succes"),
                HttpStatus.OK);
    }
}
