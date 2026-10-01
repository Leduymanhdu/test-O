package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EnterpriseMentorOptionDTO {
    private Long id;
    private String fullName;
    private String title;
    private String currentCompany;
    private BigDecimal ratingAverage;
    private Boolean available;
}
