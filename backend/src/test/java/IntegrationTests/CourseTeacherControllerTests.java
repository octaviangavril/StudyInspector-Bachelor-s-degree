package IntegrationTests;

import com.StudyInspector.StudyInspector;
import com.StudyInspector.application.model.Course;
import com.StudyInspector.application.model.Group;
import com.StudyInspector.application.model.Student;
import com.StudyInspector.application.repository.LabTeacherRepository;
import com.StudyInspector.webAPI.config.JWTGenerator;
import com.StudyInspector.webAPI.controller.CourseTeacherController;
import com.StudyInspector.webAPI.dto.CourseDataDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import com.StudyInspector.webAPI.services.CourseEntitiesDataService;
import com.StudyInspector.webAPI.services.GoogleSpreadsheetsService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@SpringBootTest(classes = StudyInspector.class)
@AutoConfigureMockMvc
class CourseTeacherControllerTests {

    @MockBean
    private LabTeacherRepository labTeacherRepository;

    @MockBean
    private GoogleSpreadsheetsService googleSpreadsheetsService;

    @MockBean
    private CourseEntitiesDataService courseEntitiesDataService;

    @MockBean
    private JWTGenerator jwtGenerator;

    @Autowired
    private CourseTeacherController courseTeacherController;

    @Test
    void testCreateCourseEntities() throws Exception {
        // Arrange
        String token = "Bearer validToken";

        when(jwtGenerator.validateToken(anyString())).thenReturn(true);

        when(courseEntitiesDataService.createCourse(any(), any(), any(), any(), any()))
                .thenReturn(new ResponseEntity<>(new HttpResponseDto("Course added", new Course()), HttpStatus.OK));

        when(courseEntitiesDataService.createGroup(any(), any(), any(), any()))
                .thenReturn(new ResponseEntity<>(new HttpResponseDto("Group added", new Group()), HttpStatus.OK));

        when(courseEntitiesDataService.createStudent(any(), any(), any(), any(), any(), any(), any()))
                .thenReturn(new ResponseEntity<>(new HttpResponseDto("Student created successfully!", new Student()), HttpStatus.OK));

        when(labTeacherRepository.findById(1L)).thenReturn(java.util.Optional.of(new com.StudyInspector.application.model.user.LabTeacher()));
        when(labTeacherRepository.findById(2L)).thenReturn(java.util.Optional.of(new com.StudyInspector.application.model.user.LabTeacher()));

        when(googleSpreadsheetsService.generateMySpreadsheet(anyString(), anyList(), anyInt(), eq(false)))
                .thenReturn("spreadsheetId1");
        when(googleSpreadsheetsService.generateMySpreadsheet(anyString(), anyList(), anyInt(), eq(true)))
                .thenReturn("spreadsheetId2");

        CourseDataDto courseDataDto = new CourseDataDto();
        courseDataDto.setCourseName("Test Course");
        courseDataDto.setSpreadsheetTemplateColumns(Arrays.asList("Test Column 1", "Test Column 2"));
        courseDataDto.setLabTeachersIds(Map.of("A", 1L, "B", 2L));
        courseDataDto.setStudentsData(Map.of("An", List.of("test"), "Grupa", List.of("test"), "Nume", List.of("test"), "Prenume", List.of("test"), "Email", List.of("test"), "Numar matricol", List.of("test"), "Numar de telefon", List.of("test")));

        // Act
        HttpResponseDto responseContent = courseTeacherController.createCourseEntities(token, 1L, courseDataDto).getBody();

        // Assert
        assertEquals("Cererea a fost procesată cu succes", responseContent.getMessage());
    }
}
