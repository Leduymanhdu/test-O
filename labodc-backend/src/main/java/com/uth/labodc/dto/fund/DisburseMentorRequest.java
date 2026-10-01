package com.uth.labodc.dto.fund;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DisburseMentorRequest {
    private Long mentorId;
    private BigDecimal amount;
    private String note;
}
