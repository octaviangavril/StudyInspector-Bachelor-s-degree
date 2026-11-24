package com.StudyInspector.webAPI.services;

import com.StudyInspector.application.model.Course;
import com.StudyInspector.application.model.Group;
import com.StudyInspector.application.model.Student;
import com.StudyInspector.webAPI.dto.CourseDto;
import com.StudyInspector.webAPI.dto.GroupDto;
import com.StudyInspector.webAPI.dto.StudentDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.Objects;

@Service
public class CourseEntitiesDataService {

    private final String BASE_URL = "http://localhost:5050/api/";
    private final RestTemplate restTemplate;
    private final GoogleSpreadsheetsService googleSpreadSheetsService;

    public CourseEntitiesDataService(GoogleSpreadsheetsService googleSpreadSheetsService) {
        this.googleSpreadSheetsService = googleSpreadSheetsService;
        this.restTemplate = new RestTemplate();
    }

    public ResponseEntity<HttpResponseDto> createStudent(String token, String firstName, String lastName, String email,
                                                         String phoneNumber, String matriculationNumber, Long groupId) {
        StudentDto studentDto = new StudentDto();
        studentDto.setFirstName(firstName);
        studentDto.setLastName(lastName);
        studentDto.setEmail(email);
        studentDto.setPhoneNumber(phoneNumber);
        studentDto.setMatriculationNumber(matriculationNumber);
        studentDto.setGroupId(groupId);

        String url = BASE_URL + "student/add";
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<StudentDto> requestEntity = new HttpEntity<>(studentDto, headers);

        return restTemplate.postForEntity(url, requestEntity, HttpResponseDto.class);
    }

    public ResponseEntity<HttpResponseDto> createCourse(String token, Long id, String courseName, String urlFileAllStudents, String privateUrlFileAllStudents) {
        CourseDto courseDto = new CourseDto();
        courseDto.setCourseName(courseName);
        courseDto.setUrlFileAllStudents(urlFileAllStudents);
        courseDto.setPrivateUrlFileAllStudents(privateUrlFileAllStudents);

        String url = BASE_URL + "course/add?id=" + id;
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<CourseDto> requestEntity = new HttpEntity<>(courseDto, headers);

        return restTemplate.postForEntity(url, requestEntity, HttpResponseDto.class);
    }

    public ResponseEntity<HttpResponseDto> createGroup(String token, Long teacherId, Long courseId, String groupName) {
        GroupDto groupDto = new GroupDto();
        groupDto.setGroupName(groupName);

        String url = BASE_URL + "group/add?teacherId=" + teacherId + "&courseId=" + courseId;
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<GroupDto> requestEntity = new HttpEntity<>(groupDto, headers);

        return restTemplate.postForEntity(url, requestEntity, HttpResponseDto.class);
    }

    public ResponseEntity<HttpResponseDto> deleteCourse(String token, Long courseId) {
        String url = BASE_URL + "course/getById?id=" + courseId;
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);

        HttpEntity<Void> requestEntity = new HttpEntity<>(headers);

        ResponseEntity<HttpResponseDto> response = restTemplate.exchange(url, HttpMethod.GET, requestEntity, HttpResponseDto.class);

        if (response.getStatusCode() != HttpStatus.OK) {
            return new ResponseEntity<>(response.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
        }

        ObjectMapper objectMapper = new ObjectMapper();
        Course course = objectMapper.convertValue(Objects.requireNonNull(response.getBody()).getPayload(), Course.class);

        for (Group group : course.getGroups()) {
            ResponseEntity<HttpResponseDto> groupResponse = deleteGroup(token, group.getId());

            if (groupResponse.getStatusCode() != HttpStatus.OK) {
                return new ResponseEntity<>(groupResponse.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        try {
            googleSpreadSheetsService.deleteSpreadsheet(course.getUrlFileAllStudents().substring("https://docs.google.com/spreadsheets/d/".length()));
            googleSpreadSheetsService.deleteSpreadsheet(course.getPrivateUrlFileAllStudents().substring("https://docs.google.com/spreadsheets/d/".length()));
        } catch (IOException e) {
            return new ResponseEntity<>(new HttpResponseDto("An error occurred while deleting the course spreadsheet: " + e.getMessage()),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }

        url = BASE_URL + "course/delete?id=" + courseId;
        return restTemplate.exchange(url, HttpMethod.DELETE, requestEntity, HttpResponseDto.class);
    }

    public ResponseEntity<HttpResponseDto> deleteGroup(String token, Long groupId) {
        String url = BASE_URL + "group/getById?id=" + groupId;
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Void> requestEntity = new HttpEntity<>(headers);

        ResponseEntity<HttpResponseDto> response = restTemplate.exchange(url, HttpMethod.GET, requestEntity, HttpResponseDto.class);

        if (response.getStatusCode() != HttpStatus.OK) {
            return new ResponseEntity<>(response.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
        }

        ObjectMapper objectMapper = new ObjectMapper();
        Group group = objectMapper.convertValue(Objects.requireNonNull(response.getBody()).getPayload(), Group.class);

        for (Student student : group.getStudents()) {
            ResponseEntity<HttpResponseDto> studentResponse = deleteStudent(token, student.getId());

            if (studentResponse.getStatusCode() != HttpStatus.OK) {
                return new ResponseEntity<>(studentResponse.getBody(), HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        url = BASE_URL + "group/delete?id=" + groupId;
        return restTemplate.exchange(url, HttpMethod.DELETE, requestEntity, HttpResponseDto.class);
    }

    public ResponseEntity<HttpResponseDto> deleteStudent(String token, Long studentId) {
        String url = BASE_URL + "student/delete?id=" + studentId;
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Void> requestEntity = new HttpEntity<>(headers);

        return restTemplate.exchange(url, HttpMethod.DELETE, requestEntity, HttpResponseDto.class);
    }
}