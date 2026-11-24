package com.StudyInspector.webAPI.dto;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class CourseDataDto {

    private String courseName;
    private Map<String, Long> labTeachersIds;
    private Map<String, List<String>> studentsData;
    private List<String> spreadsheetTemplateColumns;
}
