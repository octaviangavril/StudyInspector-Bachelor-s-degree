package UnitTests;

import com.StudyInspector.webAPI.services.GoogleSpreadsheetsService;
import com.google.api.services.drive.Drive;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.model.Spreadsheet;
import com.google.api.services.sheets.v4.model.ValueRange;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

public class GoogleSpreadsheetsServiceTest {

    @InjectMocks
    private GoogleSpreadsheetsService googleSpreadsheetsService;

    @Mock
    private Sheets sheetsService;

    @Mock
    private Drive driveService;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGenerateMySpreadsheet() throws IOException {
        // Arrange
        String title = "Test Spreadsheet";
        List<String> columns = Arrays.asList("Column1", "Column2", "Column3");
        int rows = 3;
        boolean isPrivate = false;

        Sheets.Spreadsheets spreadsheets = mock(Sheets.Spreadsheets.class);
        Sheets.Spreadsheets.Create createRequest = mock(Sheets.Spreadsheets.Create.class);
        when(sheetsService.spreadsheets()).thenReturn(spreadsheets);
        when(spreadsheets.create(any(Spreadsheet.class))).thenReturn(createRequest);
        when(createRequest.setFields(anyString())).thenReturn(createRequest);

        // Act
        String spreadsheetId = googleSpreadsheetsService.generateMySpreadsheet(title, columns, rows, isPrivate);
        List<List<String>> values = googleSpreadsheetsService.getAllData(spreadsheetId);

        // Assert
        assertEquals(columns, values.get(0));
    }

    @Test
    public void testPopulateColumn() throws IOException {
        // Arrange
        String title = "Test Spreadsheet";
        List<String> columns = Arrays.asList("Column1", "Column2", "Column3");
        int rows = 3;
        boolean isPrivate = false;

        // Mock Google Sheets service
        Sheets.Spreadsheets spreadsheets = mock(Sheets.Spreadsheets.class);
        Sheets.Spreadsheets.Create createRequest = mock(Sheets.Spreadsheets.Create.class);
        when(sheetsService.spreadsheets()).thenReturn(spreadsheets);
        when(spreadsheets.create(any(Spreadsheet.class))).thenReturn(createRequest);
        when(createRequest.setFields(anyString())).thenReturn(createRequest);

        // Act
        String spreadsheetId = googleSpreadsheetsService.generateMySpreadsheet(title, columns, rows, isPrivate);
        googleSpreadsheetsService.populateColumn(spreadsheetId, "Column1", Arrays.asList("Value1", "Value2", "Value3"));

        List<List<String>> values = googleSpreadsheetsService.getAllData(spreadsheetId);

        // Assert
        assertEquals("Value1", values.get(1).get(0));
    }

    @Test
    public void testUpdateCellValue() throws IOException {
        // Arrange
        String title = "Test Spreadsheet";
        List<String> columns = Arrays.asList("An", "Grupa", "Numar matricol", "L1", "L2", "L3", "Total");
        int rows = 3;
        boolean isPrivate = false;

        // Mock Google Sheets service
        Sheets.Spreadsheets spreadsheets = mock(Sheets.Spreadsheets.class);
        Sheets.Spreadsheets.Create createRequest = mock(Sheets.Spreadsheets.Create.class);
        when(sheetsService.spreadsheets()).thenReturn(spreadsheets);
        when(spreadsheets.create(any(Spreadsheet.class))).thenReturn(createRequest);
        when(createRequest.setFields(anyString())).thenReturn(createRequest);

        // Act
        String spreadsheetId = googleSpreadsheetsService.generateMySpreadsheet(title, columns, rows, isPrivate);
        googleSpreadsheetsService.populateColumn(spreadsheetId, "Numar matricol", Arrays.asList("1", "2", "3"));
        googleSpreadsheetsService.updateCellValue(spreadsheetId, "1","L1", "10");
        List<List<String>> values = googleSpreadsheetsService.getAllData(spreadsheetId);

        // Assert
        assertEquals("10", values.get(1).get(3));
    }

    @Test
    public void testImportRange() throws IOException {
        // Arrange
        String title1 = "Test Spreadsheet1";
        String title2 = "Test Spreadsheet2";
        List<String> columns1 = Arrays.asList("An", "Grupa", "Numar matricol", "L1", "L2", "L3", "Total");
        List<String> columns2 = Arrays.asList("An", "Grupa", "Numar matricol", "Nume", "Prenume", "L1", "L2", "L3", "Total");
        int rows = 3;
        boolean isPrivate1 = false;
        boolean isPrivate2 = true;

        Sheets.Spreadsheets spreadsheets = mock(Sheets.Spreadsheets.class);
        Sheets.Spreadsheets.Values values = mock(Sheets.Spreadsheets.Values.class);
        Sheets.Spreadsheets.Values.Get getRequest = mock(Sheets.Spreadsheets.Values.Get.class);
        Sheets.Spreadsheets.Values.Update updateRequest = mock(Sheets.Spreadsheets.Values.Update.class);

        when(sheetsService.spreadsheets()).thenReturn(spreadsheets);
        when(spreadsheets.values()).thenReturn(values);
        when(values.get(anyString(), anyString())).thenReturn(getRequest);
        when(values.update(anyString(), anyString(), any(ValueRange.class))).thenReturn(updateRequest);

        ValueRange valueRangeResponse = new ValueRange();
        List<List<Object>> valuesList = new ArrayList<>();
        valuesList.add(Arrays.asList("1", "2", "3"));
        valueRangeResponse.setValues(valuesList);

        when(getRequest.execute()).thenReturn(valueRangeResponse);

        //Act
        String spreadsheetId1 = googleSpreadsheetsService.generateMySpreadsheet(title1, columns1, rows, isPrivate1);
        String spreadsheetId2 = googleSpreadsheetsService.generateMySpreadsheet(title2, columns2, rows, isPrivate2);
        googleSpreadsheetsService.populateColumn(spreadsheetId1, "Numar matricol", Arrays.asList("1", "2", "3"));

        googleSpreadsheetsService.importRange(spreadsheetId1, spreadsheetId2);

        googleSpreadsheetsService.populateColumn(spreadsheetId1, "Grupa", Arrays.asList("A", "B", "C"));

        googleSpreadsheetsService.updateCellValue(spreadsheetId1, "1","L1", "10");
        List<List<String>> values1 = googleSpreadsheetsService.getAllData(spreadsheetId1);
        List<List<String>> values2 = googleSpreadsheetsService.getAllData(spreadsheetId2);

        List<String> matriculationNumbers1 = values1.stream().map(row -> row.get(2)).toList();
        List<String> matriculationNumbers2 = values2.stream().map(row -> row.get(2)).toList();

        // Assert
        assertEquals(matriculationNumbers1, matriculationNumbers2);

        assertEquals(values1.get(1).get(3), values2.get(1).get(5));
    }
}
