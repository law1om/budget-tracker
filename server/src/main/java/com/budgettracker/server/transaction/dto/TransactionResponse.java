package com.budgettracker.server.transaction.dto;

import com.budgettracker.server.transaction.Transaction;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponse {
    private Long id;
    private String title;
    private BigDecimal amount;
    private LocalDateTime date;
    private String categoryId;
    private String type;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static TransactionResponse fromEntity(Transaction transaction) {
        return TransactionResponse.builder()
                .id(transaction.getId())
                .title(transaction.getTitle())
                .amount(transaction.getAmount())
                .date(transaction.getDate())
                .categoryId(transaction.getCategoryId())
                .type(transaction.getType())
                .createdAt(transaction.getCreatedAt())
                .updatedAt(transaction.getUpdatedAt())
                .build();
    }
}
