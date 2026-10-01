package com.uth.labodc.service;

import com.uth.labodc.model.entity.TransparencyReport;
import com.uth.labodc.repository.TransparencyReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExcelExportService {
    
    private final TransparencyReportRepository transparencyReportRepository;
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    
    /**
     * Export transparency report to Excel
     */
    public byte[] exportTransparencyReportToExcel(Long reportId) throws IOException {
        log.info("Exporting report {} to Excel", reportId);
        
        TransparencyReport report = transparencyReportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found with id: " + reportId));
        
        try (XSSFWorkbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            
            // Create styles
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle titleStyle = createTitleStyle(workbook);
            CellStyle normalStyle = createNormalStyle(workbook);
            CellStyle numberStyle = createNumberStyle(workbook);
            CellStyle currencyStyle = createCurrencyStyle(workbook);
            
            // Create sheet
            XSSFSheet sheet = workbook.createSheet("Báo cáo minh bạch");
            sheet.setDefaultColumnWidth(20);
            
            int rowNum = 0;
            
            // Title
            Row titleRow = sheet.createRow(rowNum++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("BÁO CÁO MINH BẠCH - " + report.getPeriod());
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));
            titleRow.setHeightInPoints(30);
            
            rowNum++; // Empty row
            
            // Report info
            createInfoRow(sheet, rowNum++, "Loại báo cáo:", report.getReportType().name(), normalStyle);
            createInfoRow(sheet, rowNum++, "Kỳ báo cáo:", report.getPeriod(), normalStyle);
            createInfoRow(sheet, rowNum++, "Trạng thái:", report.getStatus().name(), normalStyle);
            if (report.getPublishedAt() != null) {
                createInfoRow(sheet, rowNum++, "Ngày xuất bản:", 
                        report.getPublishedAt().format(DATE_FORMATTER), normalStyle);
            }
            
            rowNum++; // Empty row
            
            // Statistics
            Map<String, Object> statistics = report.getStatistics();
            if (statistics != null) {
                // Project Statistics
                if (statistics.containsKey("projects")) {
                    rowNum = addProjectStats(sheet, rowNum, statistics, headerStyle, normalStyle, numberStyle);
                    rowNum++; // Empty row
                }
                
                // Enterprise Statistics
                if (statistics.containsKey("enterprises")) {
                    rowNum = addEnterpriseStats(sheet, rowNum, statistics, headerStyle, normalStyle, numberStyle);
                    rowNum++; // Empty row
                }
                
                // Talent Statistics
                if (statistics.containsKey("talents")) {
                    rowNum = addTalentStats(sheet, rowNum, statistics, headerStyle, normalStyle, numberStyle);
                    rowNum++; // Empty row
                }
                
                // Mentor Statistics
                if (statistics.containsKey("mentors")) {
                    rowNum = addMentorStats(sheet, rowNum, statistics, headerStyle, normalStyle, numberStyle);
                    rowNum++; // Empty row
                }
                
                // Financial Statistics
                if (statistics.containsKey("financials")) {
                    rowNum = addFinancialStats(sheet, rowNum, statistics, headerStyle, normalStyle, currencyStyle);
                    rowNum++; // Empty row
                }
                
                // Performance Statistics
                if (statistics.containsKey("performance")) {
                    addPerformanceStats(sheet, rowNum, statistics, headerStyle, normalStyle, numberStyle);
                }
            }
            
            // Auto-size columns
            for (int i = 0; i < 6; i++) {
                sheet.autoSizeColumn(i);
            }
            
            workbook.write(outputStream);
            log.info("Excel export completed for report {}", reportId);
            return outputStream.toByteArray();
        }
    }
    
    private void createInfoRow(Sheet sheet, int rowNum, String label, String value, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        Cell labelCell = row.createCell(0);
        labelCell.setCellValue(label);
        labelCell.setCellStyle(style);
        
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value);
        valueCell.setCellStyle(style);
    }
    
    @SuppressWarnings("unchecked")
    private int addProjectStats(Sheet sheet, int rowNum, Map<String, Object> statistics, 
                                 CellStyle headerStyle, CellStyle normalStyle, CellStyle numberStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("THỐNG KÊ DỰ ÁN");
        headerCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
        
        Map<String, Object> projects = (Map<String, Object>) statistics.get("projects");
        createStatRow(sheet, rowNum++, "Tổng số dự án:", getNumberValue(projects, "total"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Dự án mới:", getNumberValue(projects, "newProjects"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đang thực hiện:", getNumberValue(projects, "ongoing"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đã hoàn thành:", getNumberValue(projects, "completed"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đã hủy:", getNumberValue(projects, "cancelled"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Tỷ lệ thành công:", 
                String.format("%.2f%%", getDoubleValue(projects, "successRate")), normalStyle, numberStyle);
        
        return rowNum;
    }
    
    @SuppressWarnings("unchecked")
    private int addEnterpriseStats(Sheet sheet, int rowNum, Map<String, Object> statistics,
                                    CellStyle headerStyle, CellStyle normalStyle, CellStyle numberStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("THỐNG KÊ DOANH NGHIỆP");
        headerCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
        
        Map<String, Object> enterprises = (Map<String, Object>) statistics.get("enterprises");
        createStatRow(sheet, rowNum++, "Tổng số doanh nghiệp:", getNumberValue(enterprises, "total"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Doanh nghiệp mới:", getNumberValue(enterprises, "newEnterprises"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đang hoạt động:", getNumberValue(enterprises, "active"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đã xác minh:", getNumberValue(enterprises, "verified"), normalStyle, numberStyle);
        
        return rowNum;
    }
    
    @SuppressWarnings("unchecked")
    private int addTalentStats(Sheet sheet, int rowNum, Map<String, Object> statistics,
                                CellStyle headerStyle, CellStyle normalStyle, CellStyle numberStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("THỐNG KÊ SINH VIÊN");
        headerCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
        
        Map<String, Object> talents = (Map<String, Object>) statistics.get("talents");
        createStatRow(sheet, rowNum++, "Tổng số sinh viên:", getNumberValue(talents, "total"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Sinh viên mới:", getNumberValue(talents, "newTalents"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đang hoạt động:", getNumberValue(talents, "active"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Điểm đánh giá TB:", 
                String.format("%.2f/5.0", getDoubleValue(talents, "averageRating")), normalStyle, numberStyle);
        
        return rowNum;
    }
    
    @SuppressWarnings("unchecked")
    private int addMentorStats(Sheet sheet, int rowNum, Map<String, Object> statistics,
                                CellStyle headerStyle, CellStyle normalStyle, CellStyle numberStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("THỐNG KÊ MENTOR");
        headerCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
        
        Map<String, Object> mentors = (Map<String, Object>) statistics.get("mentors");
        createStatRow(sheet, rowNum++, "Tổng số mentor:", getNumberValue(mentors, "total"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Đang hoạt động:", getNumberValue(mentors, "active"), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Điểm đánh giá TB:", 
                String.format("%.2f/5.0", getDoubleValue(mentors, "averageRating")), normalStyle, numberStyle);
        
        return rowNum;
    }
    
    @SuppressWarnings("unchecked")
    private int addFinancialStats(Sheet sheet, int rowNum, Map<String, Object> statistics,
                                   CellStyle headerStyle, CellStyle normalStyle, CellStyle currencyStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("THỐNG KÊ TÀI CHÍNH");
        headerCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
        
        Map<String, Object> financials = (Map<String, Object>) statistics.get("financials");
        createCurrencyRow(sheet, rowNum++, "Tổng doanh thu:", getBigDecimalValue(financials, "totalRevenue"), normalStyle, currencyStyle);
        createCurrencyRow(sheet, rowNum++, "Chi trả cho đội (70%):", getBigDecimalValue(financials, "teamDisbursed"), normalStyle, currencyStyle);
        createCurrencyRow(sheet, rowNum++, "Chi trả cho mentor (20%):", getBigDecimalValue(financials, "mentorDisbursed"), normalStyle, currencyStyle);
        createCurrencyRow(sheet, rowNum++, "Doanh thu Lab (10%):", getBigDecimalValue(financials, "labRevenue"), normalStyle, currencyStyle);
        createCurrencyRow(sheet, rowNum++, "Quỹ hỗn hợp ứng trước:", getBigDecimalValue(financials, "hybridFundAdvanced"), normalStyle, currencyStyle);
        createCurrencyRow(sheet, rowNum++, "Quỹ hỗn hợp hoàn trả:", getBigDecimalValue(financials, "hybridFundRepaid"), normalStyle, currencyStyle);
        
        return rowNum;
    }
    
    @SuppressWarnings("unchecked")
    private int addPerformanceStats(Sheet sheet, int rowNum, Map<String, Object> statistics,
                                     CellStyle headerStyle, CellStyle normalStyle, CellStyle numberStyle) {
        Row headerRow = sheet.createRow(rowNum++);
        Cell headerCell = headerRow.createCell(0);
        headerCell.setCellValue("HIỆU SUẤT");
        headerCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 5));
        
        Map<String, Object> performance = (Map<String, Object>) statistics.get("performance");
        createStatRow(sheet, rowNum++, "Tỷ lệ hoàn thành TB:", 
                String.format("%.2f%%", getDoubleValue(performance, "avgProjectCompletion")), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Giao hàng đúng hạn:", 
                String.format("%.2f%%", getDoubleValue(performance, "onTimeDelivery")), normalStyle, numberStyle);
        createStatRow(sheet, rowNum++, "Sự hài lòng khách hàng:", 
                String.format("%.2f/5.0", getDoubleValue(performance, "customerSatisfaction")), normalStyle, numberStyle);
        
        return rowNum;
    }
    
    private void createStatRow(Sheet sheet, int rowNum, String label, String value, 
                                CellStyle normalStyle, CellStyle numberStyle) {
        Row row = sheet.createRow(rowNum);
        Cell labelCell = row.createCell(0);
        labelCell.setCellValue(label);
        labelCell.setCellStyle(normalStyle);
        
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value);
        valueCell.setCellStyle(numberStyle);
    }
    
    private void createCurrencyRow(Sheet sheet, int rowNum, String label, BigDecimal value,
                                    CellStyle normalStyle, CellStyle currencyStyle) {
        Row row = sheet.createRow(rowNum);
        Cell labelCell = row.createCell(0);
        labelCell.setCellValue(label);
        labelCell.setCellStyle(normalStyle);
        
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value.doubleValue());
        valueCell.setCellStyle(currencyStyle);
    }
    
    // Helper methods
    private String getNumberValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Number) {
            return String.valueOf(((Number) value).longValue());
        }
        return "0";
    }
    
    private double getDoubleValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        return 0.0;
    }
    
    private BigDecimal getBigDecimalValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        } else if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        return BigDecimal.ZERO;
    }
    
    // Style creators
    private CellStyle createTitleStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 16);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }
    
    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_GREEN.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }
    
    private CellStyle createNormalStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }
    
    private CellStyle createNumberStyle(Workbook workbook) {
        CellStyle style = createNormalStyle(workbook);
        style.setAlignment(HorizontalAlignment.RIGHT);
        return style;
    }
    
    private CellStyle createCurrencyStyle(Workbook workbook) {
        CellStyle style = createNormalStyle(workbook);
        DataFormat format = workbook.createDataFormat();
        style.setDataFormat(format.getFormat("#,##0 \"VNĐ\""));
        style.setAlignment(HorizontalAlignment.RIGHT);
        return style;
    }
}
