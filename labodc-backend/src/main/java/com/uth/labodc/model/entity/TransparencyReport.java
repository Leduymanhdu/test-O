package com.uth.labodc.model.entity;

import com.uth.labodc.model.enums.ReportStatus;
import com.uth.labodc.model.enums.ReportType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "transparency_reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransparencyReport {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "report_type", nullable = false)
    private ReportType reportType;
    
    @Column(name = "period", nullable = false, length = 7)
    private String period; // YYYY-MM format
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "statistics", nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> statistics;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "charts_data", columnDefinition = "jsonb")
    private Map<String, Object> chartsData;
    
    @Column(name = "publish_note", columnDefinition = "TEXT")
    private String publishNote;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private ReportStatus status = ReportStatus.DRAFT;
    
    @Column(name = "public_url", length = 500)
    private String publicUrl;
    
    @Column(name = "pdf_url", length = 500)
    private String pdfUrl;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;
    
    @Column(name = "published_at")
    private LocalDateTime publishedAt;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = ReportStatus.DRAFT;
        }
    }
}
