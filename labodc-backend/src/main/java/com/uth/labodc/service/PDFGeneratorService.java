package com.uth.labodc.service;

import com.uth.labodc.dto.report.TransparencyReportDTO;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Service
@Slf4j
public class PDFGeneratorService {

    private static final float MARGIN = 50;
    private static final float FONT_SIZE_TITLE = 22;
    private static final float FONT_SIZE_SECTION = 16;
    private static final float FONT_SIZE_NORMAL = 11;
    private static final float LINE_HEIGHT = 18;
    private static final float SECTION_SPACING = 25;
    private static final float INDENT = 30;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /**
     * Generate PDF from transparency report data
     * 
     * @param report Report DTO
     * @return PDF as byte array
     */
    public byte[] generateReportPDF(TransparencyReportDTO report) {
        try {
            log.info("Generating PDF for report: {}", report.getReportId());
            
            PDDocument document = new PDDocument();
            PDPage page = new PDPage(PDRectangle.A4);
            document.addPage(page);
            
            PDPageContentStream contentStream = new PDPageContentStream(document, page);
            float yPosition = page.getMediaBox().getHeight() - MARGIN;
            
            // Title
            yPosition = drawTitle(contentStream, "TRANSPARENCY REPORT", yPosition);
            yPosition -= LINE_HEIGHT * 2;
            
            // Report Info
            yPosition = drawSectionHeader(contentStream, "REPORT INFORMATION", yPosition);
            yPosition = drawKeyValue(contentStream, "Report ID", String.valueOf(report.getReportId()), yPosition);
            yPosition = drawKeyValue(contentStream, "Period", report.getPeriod(), yPosition);
            yPosition = drawKeyValue(contentStream, "Type", report.getReportType(), yPosition);
            yPosition = drawKeyValue(contentStream, "Status", report.getStatus(), yPosition);
            
            if (report.getCreatedAt() != null) {
                yPosition = drawKeyValue(contentStream, "Created", report.getCreatedAt().format(DATE_FORMATTER), yPosition);
            }
            if (report.getPublishedAt() != null) {
                yPosition = drawKeyValue(contentStream, "Published", report.getPublishedAt().format(DATE_FORMATTER), yPosition);
            }
            yPosition -= SECTION_SPACING;
            
            // Statistics
            if (report.getStatistics() != null) {
                TransparencyReportDTO.ReportStatistics stats = report.getStatistics();
                
                // Project Stats
                if (stats.getProjects() != null) {
                    yPosition = drawSectionHeader(contentStream, "PROJECT STATISTICS", yPosition);
                    yPosition = drawKeyValue(contentStream, "Total Projects", String.valueOf(stats.getProjects().getTotal()), yPosition);
                    yPosition = drawKeyValue(contentStream, "New Projects", String.valueOf(stats.getProjects().getNewProjects()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Ongoing", String.valueOf(stats.getProjects().getOngoing()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Completed", String.valueOf(stats.getProjects().getCompleted()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Cancelled", String.valueOf(stats.getProjects().getCancelled()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Success Rate", String.format("%.1f%%", stats.getProjects().getSuccessRate()), yPosition);
                    yPosition -= SECTION_SPACING;
                }
                
                // Enterprise Stats
                if (stats.getEnterprises() != null) {
                    PageContext ctx = checkNewPage(document, contentStream, yPosition);
                    contentStream = ctx.contentStream;
                    yPosition = ctx.yPosition;
                    yPosition = drawSectionHeader(contentStream, "ENTERPRISE STATISTICS", yPosition);
                    yPosition = drawKeyValue(contentStream, "Total Enterprises", String.valueOf(stats.getEnterprises().getTotal()), yPosition);
                    yPosition = drawKeyValue(contentStream, "New Enterprises", String.valueOf(stats.getEnterprises().getNewEnterprises()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Active", String.valueOf(stats.getEnterprises().getActive()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Verified", String.valueOf(stats.getEnterprises().getVerified()), yPosition);
                    yPosition -= SECTION_SPACING;
                }
                
                // Talent Stats
                if (stats.getTalents() != null) {
                    PageContext ctx = checkNewPage(document, contentStream, yPosition);
                    contentStream = ctx.contentStream;
                    yPosition = ctx.yPosition;
                    yPosition = drawSectionHeader(contentStream, "TALENT STATISTICS", yPosition);
                    yPosition = drawKeyValue(contentStream, "Total Talents", String.valueOf(stats.getTalents().getTotal()), yPosition);
                    yPosition = drawKeyValue(contentStream, "New Talents", String.valueOf(stats.getTalents().getNewTalents()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Active", String.valueOf(stats.getTalents().getActive()), yPosition);
                    yPosition -= SECTION_SPACING;
                }
                
                // Mentor Stats  
                if (stats.getMentors() != null) {
                    PageContext ctx = checkNewPage(document, contentStream, yPosition);
                    contentStream = ctx.contentStream;
                    yPosition = ctx.yPosition;
                    yPosition = drawSectionHeader(contentStream, "MENTOR STATISTICS", yPosition);
                    yPosition = drawKeyValue(contentStream, "Total Mentors", String.valueOf(stats.getMentors().getTotal()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Active", String.valueOf(stats.getMentors().getActive()), yPosition);
                    yPosition -= SECTION_SPACING;
                }
                
                // Financial Stats
                if (stats.getFinancials() != null) {
                    PageContext ctx = checkNewPage(document, contentStream, yPosition);
                    contentStream = ctx.contentStream;
                    yPosition = ctx.yPosition;
                    yPosition = drawSectionHeader(contentStream, "FINANCIAL STATISTICS", yPosition);
                    yPosition = drawKeyValue(contentStream, "Total Revenue", formatCurrency(stats.getFinancials().getTotalRevenue()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Team Disbursed", formatCurrency(stats.getFinancials().getTeamDisbursed()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Mentor Disbursed", formatCurrency(stats.getFinancials().getMentorDisbursed()), yPosition);
                    yPosition = drawKeyValue(contentStream, "Lab Revenue", formatCurrency(stats.getFinancials().getLabRevenue()), yPosition);
                }
            }
            
            contentStream.close();
            
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            document.save(baos);
            document.close();
            
            log.info("PDF generated successfully for report: {}", report.getReportId());
            return baos.toByteArray();
            
        } catch (Exception e) {
            log.error("Failed to generate PDF for report: {}", report.getReportId(), e);
            throw new RuntimeException("Failed to generate PDF: " + e.getMessage());
        }
    }
    
    private float drawTitle(PDPageContentStream contentStream, String text, float yPosition) throws IOException {
        // Center title
        float titleWidth = PDType1Font.HELVETICA_BOLD.getStringWidth(text) / 1000 * FONT_SIZE_TITLE;
        float centerX = (PDRectangle.A4.getWidth() - titleWidth) / 2;
        
        contentStream.beginText();
        contentStream.setFont(PDType1Font.HELVETICA_BOLD, FONT_SIZE_TITLE);
        contentStream.newLineAtOffset(centerX, yPosition);
        contentStream.showText(text);
        contentStream.endText();
        
        // Draw underline
        yPosition -= 5;
        contentStream.moveTo(MARGIN, yPosition);
        contentStream.lineTo(PDRectangle.A4.getWidth() - MARGIN, yPosition);
        contentStream.stroke();
        
        return yPosition - SECTION_SPACING;
    }
    
    private float drawSectionHeader(PDPageContentStream contentStream, String text, float yPosition) throws IOException {
        // Draw background box
        contentStream.setNonStrokingColor(0.9f, 0.9f, 0.9f); // Light gray
        contentStream.addRect(MARGIN - 5, yPosition - 5, PDRectangle.A4.getWidth() - 2 * MARGIN + 10, LINE_HEIGHT + 5);
        contentStream.fill();
        contentStream.setNonStrokingColor(0f, 0f, 0f); // Black text
        
        contentStream.beginText();
        contentStream.setFont(PDType1Font.HELVETICA_BOLD, FONT_SIZE_SECTION);
        contentStream.newLineAtOffset(MARGIN, yPosition);
        contentStream.showText(text);
        contentStream.endText();
        return yPosition - LINE_HEIGHT * 2;
    }
    
    private float drawText(PDPageContentStream contentStream, String text, float yPosition) throws IOException {
        contentStream.beginText();
        contentStream.setFont(PDType1Font.HELVETICA, FONT_SIZE_NORMAL);
        contentStream.newLineAtOffset(MARGIN + INDENT, yPosition);
        contentStream.showText(text);
        contentStream.endText();
        return yPosition - LINE_HEIGHT;
    }
    
    private float drawKeyValue(PDPageContentStream contentStream, String key, String value, float yPosition) throws IOException {
        // Draw key (bold)
        contentStream.beginText();
        contentStream.setFont(PDType1Font.HELVETICA_BOLD, FONT_SIZE_NORMAL);
        contentStream.newLineAtOffset(MARGIN + INDENT, yPosition);
        contentStream.showText(key + ":");
        contentStream.endText();
        
        // Draw value (normal, aligned to the right side)
        contentStream.beginText();
        contentStream.setFont(PDType1Font.HELVETICA, FONT_SIZE_NORMAL);
        contentStream.newLineAtOffset(MARGIN + 250, yPosition);
        contentStream.showText(value);
        contentStream.endText();
        
        return yPosition - LINE_HEIGHT;
    }
    
    private static class PageContext {
        PDPageContentStream contentStream;
        float yPosition;
        
        PageContext(PDPageContentStream contentStream, float yPosition) {
            this.contentStream = contentStream;
            this.yPosition = yPosition;
        }
    }
    
    private PageContext checkNewPage(PDDocument document, PDPageContentStream contentStream, float yPosition) throws IOException {
        if (yPosition < MARGIN + 100) {
            contentStream.close();
            PDPage newPage = new PDPage(PDRectangle.A4);
            document.addPage(newPage);
            PDPageContentStream newStream = new PDPageContentStream(document, newPage);
            return new PageContext(newStream, newPage.getMediaBox().getHeight() - MARGIN);
        }
        return new PageContext(contentStream, yPosition);
    }
    
    private String formatCurrency(java.math.BigDecimal amount) {
        if (amount == null) return "0 VND";
        return String.format("%,.0f VND", amount);
    }
}
