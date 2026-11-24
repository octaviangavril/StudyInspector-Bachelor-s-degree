package com.StudyInspector.webAPI.services;

import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.json.GoogleJsonError;
import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.DriveScopes;
import com.google.api.services.drive.model.Permission;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.SheetsScopes;
import com.google.api.services.sheets.v4.model.*;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.*;

@Service
public class GoogleSpreadsheetsService {
    private static final String APPLICATION_NAME = "StudyInspector";
    private static final JsonFactory JSON_FACTORY = JacksonFactory.getDefaultInstance();
    private static final String SERVICE_ACCOUNT_FILE_PATH = "/service-account-credentials.json";
    private final Sheets sheetsService;
    private final Drive driveService;

    public GoogleSpreadsheetsService() {
        try {
            sheetsService = createSheetsService();
            driveService = createDriveService();
        } catch (IOException e) {
            throw new RuntimeException("Failed to create Google Sheets service", e);
        }
    }

    public Sheets createSheetsService() throws IOException {
        HttpTransport httpTransport = new NetHttpTransport();

        GoogleCredential credential = GoogleCredential.fromStream(Objects.requireNonNull(getClass().getResourceAsStream(SERVICE_ACCOUNT_FILE_PATH)))
                .createScoped(Arrays.asList(SheetsScopes.SPREADSHEETS, DriveScopes.DRIVE));

        return new Sheets.Builder(httpTransport, JSON_FACTORY, credential)
                .setApplicationName(APPLICATION_NAME)
                .build();
    }

    public Drive createDriveService() throws IOException {
        HttpTransport httpTransport = new NetHttpTransport();

        GoogleCredential credential = GoogleCredential.fromStream(Objects.requireNonNull(getClass().getResourceAsStream(SERVICE_ACCOUNT_FILE_PATH)))
                .createScoped(Arrays.asList(SheetsScopes.SPREADSHEETS, DriveScopes.DRIVE));

        return new Drive.Builder(httpTransport, JSON_FACTORY, credential)
                .setApplicationName(APPLICATION_NAME)
                .build();
    }

    public String generateMySpreadsheet(String title, List<String> columns, int rows, boolean isPrivate) throws IOException {
        String skipColumns = "D";
        if (isPrivate){
            skipColumns = "F";
        }
        Spreadsheet spreadsheet = new Spreadsheet()
                .setProperties(new SpreadsheetProperties()
                        .setTitle(title));
        spreadsheet = sheetsService.spreadsheets().create(spreadsheet)
                .setFields("spreadsheetId")
                .execute();

        String spreadsheetId = spreadsheet.getSpreadsheetId();

        char lastColumnLetter = (char) ('A' + columns.size() - 1);
        String lastColumn = String.valueOf(lastColumnLetter);

        List<List<Object>> values = new ArrayList<>();
        values.add(new ArrayList<>(columns));

        for (int i = 0; i < rows; i++) {
            List<Object> rowValues = new ArrayList<>();
            for (int j = 0; j < columns.size() - 1; j++) {
                rowValues.add("");
            }
            String formula = "=SUM(" + skipColumns + (i + 2) + ":" + ((char) ('A' + columns.size() - 2)) + (i + 2) + ")";
            rowValues.add(formula);
            values.add(rowValues);
        }

        ValueRange body = new ValueRange().setValues(values);
        UpdateValuesResponse result = sheetsService.spreadsheets().values()
                .update(spreadsheetId, "A1:" + lastColumn + (rows + 1), body)
                .setValueInputOption("USER_ENTERED")
                .execute();

        if (!isPrivate) {
            Permission permission = new Permission()
                    .setType("anyone")
                    .setRole("reader");
            driveService.permissions().create(spreadsheetId, permission).execute();
        }

        return spreadsheetId;
    }

    public void populateColumn(String spreadsheetId, String column, List<String> values) throws IOException {
        ValueRange response = sheetsService.spreadsheets().values()
                .get(spreadsheetId, "1:1")
                .execute();
        List<Object> columns = response.getValues().get(0);

        String columnLetter = null;
        int columnIndex = -1;
        for (int i = 0; i < columns.size(); i++) {
            String cellValue = (String) columns.get(i);
            if (cellValue.equals(column)) {
                columnLetter = String.valueOf((char) ('A' + i));
                columnIndex = i;
                break;
            }
        }

        List<List<Object>> valuesList = new ArrayList<>();
        for (String value : values) {
            valuesList.add(Collections.singletonList(value));
        }
        ValueRange body = new ValueRange().setValues(valuesList);
        UpdateValuesResponse result;
        try {
            result = sheetsService.spreadsheets().values()
                    .update(spreadsheetId, columnLetter + "2:" + columnLetter + (values.size() + 1), body)
                    .setValueInputOption("USER_ENTERED")
                    .execute();
        } catch (GoogleJsonResponseException e) {
            GoogleJsonError error = e.getDetails();
            if (error.getCode() == 404) {
                System.out.printf("Spreadsheet not found with id '%s'.\n", spreadsheetId);
            } else {
                throw e;
            }
        }

        if(Objects.equals(column, "Numar matricol")) {
            setColumnWidthToFitValues(spreadsheetId, columnLetter, columnIndex);
        }
    }

    private void setColumnWidthToFitValues(String spreadsheetId, String columnLetter, int columnIndex) throws IOException {
        ValueRange columnData = sheetsService.spreadsheets().values()
                .get(spreadsheetId, columnLetter + ":" + columnLetter)
                .execute();

        List<List<Object>> values = columnData.getValues();
        if (values == null || values.isEmpty()) {
            return;
        }

        int maxWidth = 0;
        for (List<Object> row : values) {
            if (row != null && !row.isEmpty()) {
                String cellValue = (String) row.get(0);
                int cellWidth = cellValue.length();
                maxWidth = Math.max(maxWidth, cellWidth);
            }
        }

        sheetsService.spreadsheets().batchUpdate(spreadsheetId, new BatchUpdateSpreadsheetRequest()
                        .setRequests(Collections.singletonList(new Request()
                                .setUpdateDimensionProperties(new UpdateDimensionPropertiesRequest()
                                        .setRange(new DimensionRange()
                                                .setSheetId(0)
                                                .setDimension("COLUMNS")
                                                .setStartIndex(columnIndex)
                                                .setEndIndex(columnIndex + 1))
                                        .setProperties(new DimensionProperties()
                                                .setPixelSize(maxWidth * 10))
                                        .setFields("pixelSize")))))
                .execute();
    }

    public void deleteSpreadsheet(String spreadsheetId) throws IOException {
        driveService.files().delete(spreadsheetId).execute();
    }

    public int getRowNumberByValue(String spreadsheetId, String value) throws IOException {
        ValueRange response = sheetsService.spreadsheets().values()
                .get(spreadsheetId, "C:C")
                .execute();

        List<List<Object>> values = response.getValues();

        for (int i = 1; i < values.size(); i++) {
            List<Object> row = values.get(i);
            if (!row.isEmpty() && row.get(0) != null && row.get(0).toString().equals(value)) {
                return i + 1;
            }
        }

        return -1;
    }

    private String getLastColumnLetter(String spreadsheetId) throws IOException {
        ValueRange response = sheetsService.spreadsheets().values()
                .get(spreadsheetId, "Sheet1!1:1")
                .setMajorDimension("ROWS")
                .execute();

        List<Object> columns = response.getValues().get(0);

        return String.valueOf((char) ('A' + columns.size() - 1));
    }

    public void updateCellValue(String spreadsheetId, String getRowValue, String columnName, String newValue) throws IOException {
        int rowNumber = getRowNumberByValue(spreadsheetId, getRowValue);
        String endColumnLetter = getLastColumnLetter(spreadsheetId);

        ValueRange columnNamesResponse = sheetsService.spreadsheets().values()
                .get(spreadsheetId, "Sheet1!A1:" + endColumnLetter + "1")
                .setMajorDimension("ROWS")
                .execute();

        ValueRange response = sheetsService.spreadsheets().values()
                .get(spreadsheetId, "Sheet1!A" + rowNumber + ":" + endColumnLetter + rowNumber)
                .setMajorDimension("ROWS")
                .setValueRenderOption("FORMULA")
                .execute();

        List<Object> rowValues = response.getValues().get(0);

        for (int i = 0; i < rowValues.size(); i++) {
            if(columnName.equals(columnNamesResponse.getValues().get(0).get(i))) {
                if (columnName.equals("Grupa")) {
                    rowValues.set(i, newValue);
                } else {
                    rowValues.set(i, Double.parseDouble(newValue));
                }
            }
        }

        ValueRange updateBody = new ValueRange().setValues(Collections.singletonList(rowValues));
        sheetsService.spreadsheets().values()
                .update(spreadsheetId, "Sheet1!A" + rowNumber + ":" + endColumnLetter + rowNumber, updateBody)
                .setValueInputOption("USER_ENTERED")
                .execute();
    }

    public Map<String, List<String>> getStudentsTable(String spreadSheetId, List<String> studentsMatriculationNumbers) throws IOException {
        String endColumnLetter = getLastColumnLetter(spreadSheetId);

        ValueRange response = sheetsService.spreadsheets().values()
                .get(spreadSheetId, "Sheet1!A1:" + endColumnLetter)
                .execute();
        List<List<Object>> values = response.getValues();
        Map<String, List<String>> studentsTable = new LinkedHashMap<>();

        for (List<Object> row : values.subList(1, values.size())) {
            if (row != null && !row.isEmpty()) {
                String matriculationNumber = row.get(2).toString().trim();
                if (studentsMatriculationNumbers.contains(matriculationNumber)) {
                    for (int j = 0; j < row.size(); j++) {
                        String columnName = values.get(0).get(j).toString();
                        String value = row.get(j).toString();
                        List<String> studentsData = studentsTable.getOrDefault(columnName, new ArrayList<>());
                        studentsData.add(value);
                        studentsTable.put(columnName, studentsData);
                    }
                }
            }
        }

        studentsTable.remove("Grupa");

        return studentsTable;
    }

    public List<List<String>> getAllData(String spreadSheetId) throws IOException {
        String endColumnLetter = getLastColumnLetter(spreadSheetId);

        ValueRange response = sheetsService.spreadsheets().values()
                .get(spreadSheetId, "Sheet1!A1:" + endColumnLetter)
                .execute();
        List<List<Object>> values = response.getValues();

        List<List<String>> allData = new ArrayList<>();

        for (List<Object> row : values) {
            List<String> rowData = new ArrayList<>();
            for (Object cell : row) {
                rowData.add(cell.toString());
            }
            allData.add(rowData);
        }

        return allData;
    }

    public void importRange(String sourceSpreadsheetId, String destinationSpreadsheetId) throws IOException {

        ValueRange response = sheetsService.spreadsheets().values()
                .get(sourceSpreadsheetId, "Sheet1!C:C")
                .execute();
        List<List<Object>> values = response.getValues();

        int colLength =values.toArray().length;
        String sourceEndColumnLetter = String.valueOf((char) ((getLastColumnLetter(sourceSpreadsheetId).charAt(0)) - 1));

        String importFormula = "=IMPORTRANGE(\"https://docs.google.com/spreadsheets/d/" + sourceSpreadsheetId + "\", \"Sheet1!D2:" + sourceEndColumnLetter + colLength + "\")";
        List<List<Object>> formulaValue = new ArrayList<>();
        formulaValue.add(Collections.singletonList(importFormula));

        ValueRange body = new ValueRange().setValues(formulaValue);
        sheetsService.spreadsheets().values()
                .update(destinationSpreadsheetId, "Sheet1!F2", body)
                .setValueInputOption("USER_ENTERED")
                .execute();

        importFormula = "=IMPORTRANGE(\"https://docs.google.com/spreadsheets/d/" + sourceSpreadsheetId + "\", \"Sheet1!A2:C" + colLength + "\")";
        formulaValue = new ArrayList<>();
        formulaValue.add(Collections.singletonList(importFormula));

        body = new ValueRange().setValues(formulaValue);
        sheetsService.spreadsheets().values()
                .update(destinationSpreadsheetId, "Sheet1!A2", body)
                .setValueInputOption("USER_ENTERED")
                .execute();
    }

}
