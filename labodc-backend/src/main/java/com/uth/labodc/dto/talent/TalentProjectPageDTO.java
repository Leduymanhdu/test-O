package com.uth.labodc.dto.talent;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TalentProjectPageDTO {
    private List<TalentProjectDTO> content;
    private long totalElements;
    private int totalPages;
    private int size;
    private int number;
}
